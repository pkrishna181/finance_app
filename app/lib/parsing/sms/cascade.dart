import '../../core/models/sms_parse_models.dart';
import '../../core/result/result.dart';
import 'extractors.dart';
import 'sender_matcher.dart';
import 'template.dart';
import 'templates/axis.dart';
import 'templates/generic.dart';
import 'templates/hdfc.dart';
import 'templates/icici.dart';
import 'templates/kotak.dart';
import 'templates/paytm.dart';
import 'templates/sbi.dart';

/// Ordered SMS parse cascade.
///
/// 1. Normalize body
/// 2. Noise filter (OTP / promo / balance-only / EMI reminder)
/// 3. Sender match (P-suffix → skip)
/// 4. Mandate / future-debit notice
/// 5. Bank templates (first match wins)
/// 6. Generic UPI/IMPS/NEFT templates
/// 7. Err([UnparsedSms])
class SmsParseCascade {
  SmsParseCascade({Map<String, List<SmsTemplate>>? bankTemplates})
      : _bankTemplates = bankTemplates ?? _defaultBankTemplates;

  final Map<String, List<SmsTemplate>> _bankTemplates;
  final List<SmsTemplate> _generic = genericTemplates();

  Result<SmsParseSuccess> run({
    required String body,
    String? sender,
    DateTime? receivedAt,
  }) {
    final normalized = normalizeSmsBody(body);
    if (normalized.isEmpty) {
      return const Ok(SmsParseSuccess.skipped('empty'));
    }

    final noise = detectNoise(normalized);
    if (noise != null) {
      return Ok(SmsParseSuccess.skipped(noise));
    }

    final matched = matchSender(sender);
    if (!matched.isTransactional) {
      return const Ok(SmsParseSuccess.skipped('promotional_sender'));
    }

    final bank = matched.bankCode;

    final mandate = tryParseMandate(
      normalized,
      bankCode: bank == 'UNKNOWN' ? _guessBankFromBody(normalized) : bank,
      sender: sender,
      receivedAt: receivedAt,
    );
    if (mandate != null) {
      return Ok(SmsParseSuccess.mandate(mandate));
    }

    final bankCodeForTemplates =
        bank == 'UNKNOWN' ? _guessBankFromBody(normalized) : bank;

    final bankList = _bankTemplates[bankCodeForTemplates];
    if (bankList != null) {
      for (final t in bankList) {
        final txn = t.tryParse(
          normalized,
          bankOverride: bankCodeForTemplates,
          receivedAt: receivedAt,
        );
        if (txn != null) {
          return Ok(SmsParseSuccess.transactions([txn]));
        }
      }
    }

    // Also try all bank template sets if body names a bank but sender unknown
    if (bank == 'UNKNOWN') {
      for (final entry in _bankTemplates.entries) {
        for (final t in entry.value) {
          final txn = t.tryParse(
            normalized,
            bankOverride: entry.key,
            receivedAt: receivedAt,
          );
          if (txn != null) {
            return Ok(SmsParseSuccess.transactions([txn]));
          }
        }
      }
    }

    for (final t in _generic) {
      final txn = t.tryParse(
        normalized,
        bankOverride:
            bankCodeForTemplates == 'UNKNOWN' ? null : bankCodeForTemplates,
        receivedAt: receivedAt,
      );
      if (txn != null) {
        return Ok(SmsParseSuccess.transactions([txn]));
      }
    }

    return Err(
      'unparsed_sms',
      UnparsedSms(
        rawBody: normalized,
        sender: sender,
        receivedAt: receivedAt,
        bankCode: bankCodeForTemplates == 'UNKNOWN' ? null : bankCodeForTemplates,
      ),
    );
  }

  static String _guessBankFromBody(String body) {
    final upper = body.toUpperCase();
    // Prefer whole-word / branded phrases over UTR prefixes (SBIN…).
    if (RegExp(r'\bHDFC\b').hasMatch(upper)) return 'HDFC';
    if (RegExp(r'\bICICI\b').hasMatch(upper)) return 'ICICI';
    if (RegExp(r'\bAXIS\b').hasMatch(upper)) return 'AXIS';
    if (RegExp(r'\bKOTAK\b').hasMatch(upper)) return 'KOTAK';
    if (RegExp(r'\bPAYTM\b').hasMatch(upper)) return 'PAYTM';
    if (RegExp(r'\bSBI\b').hasMatch(upper)) return 'SBI';
    return 'UNKNOWN';
  }
}

final _defaultBankTemplates = <String, List<SmsTemplate>>{
  'HDFC': hdfcTemplates(),
  'SBI': sbiTemplates(),
  'ICICI': iciciTemplates(),
  'AXIS': axisTemplates(),
  'KOTAK': kotakTemplates(),
  'PAYTM': paytmTemplates(),
};

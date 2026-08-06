import '../core/db/database.dart';
import 'anchoring.dart';

/// Local-only model-quality ledger — never leaves the device.
enum LlmDisagreementField {
  direction,
  merchantDemoted,
  vpaDropped,
  refDropped,
  amountRejected,
  dateRejected;

  String get wireName => switch (this) {
        LlmDisagreementField.direction => 'direction',
        LlmDisagreementField.merchantDemoted => 'merchant_demoted',
        LlmDisagreementField.vpaDropped => 'vpa_dropped',
        LlmDisagreementField.refDropped => 'ref_dropped',
        LlmDisagreementField.amountRejected => 'amount_rejected',
        LlmDisagreementField.dateRejected => 'date_rejected',
      };
}

/// Persists anchor disagreements from [report] vs original [llmJson].
class LlmDisagreementRecorder {
  LlmDisagreementRecorder(this.db);

  final ArthDatabase db;

  Future<void> recordFromAnchor({
    required AnchorReport report,
    required Map<String, Object?> llmJson,
    required Map<String, Object?> cleaned,
    int? jobId,
  }) async {
    for (final field in report.fields) {
      switch (field.field) {
        case 'direction':
          if (field.status == AnchorFieldStatus.override) {
            await db.insertLlmDisagreement(
              jobId: jobId,
              field: LlmDisagreementField.direction.wireName,
              llmValue: llmJson['direction']?.toString() ?? '',
              resolvedValue: cleaned['direction']?.toString() ?? '',
            );
          }
        case 'raw_merchant':
          if (field.status == AnchorFieldStatus.demote) {
            await db.insertLlmDisagreement(
              jobId: jobId,
              field: LlmDisagreementField.merchantDemoted.wireName,
              llmValue: llmJson['raw_merchant']?.toString() ?? '',
              resolvedValue: cleaned['raw_merchant']?.toString() ?? '',
            );
          }
        case 'upi_payee_vpa':
        case 'upi_payer_vpa':
          if (field.status == AnchorFieldStatus.reject) {
            await db.insertLlmDisagreement(
              jobId: jobId,
              field: LlmDisagreementField.vpaDropped.wireName,
              llmValue: llmJson[field.field]?.toString() ?? '',
              resolvedValue: '',
            );
          }
        case 'upi_ref':
        case 'external_ref':
          if (field.status == AnchorFieldStatus.reject) {
            await db.insertLlmDisagreement(
              jobId: jobId,
              field: LlmDisagreementField.refDropped.wireName,
              llmValue: llmJson[field.field]?.toString() ?? '',
              resolvedValue: '',
            );
          }
        case 'amount_paise':
          if (field.status == AnchorFieldStatus.reject) {
            await db.insertLlmDisagreement(
              jobId: jobId,
              field: LlmDisagreementField.amountRejected.wireName,
              llmValue: llmJson['amount_paise']?.toString() ?? '',
              resolvedValue: '',
            );
          }
        case 'booked_at':
          if (field.status == AnchorFieldStatus.reject) {
            await db.insertLlmDisagreement(
              jobId: jobId,
              field: LlmDisagreementField.dateRejected.wireName,
              llmValue: llmJson['booked_at']?.toString() ?? '',
              resolvedValue: '',
            );
          }
        default:
          break;
      }
    }
  }
}

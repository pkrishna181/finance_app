import 'dart:convert';

import '../../core/models/models.dart';
import '../../parsing/common/extractors.dart';
import '../../parsing/sms/template.dart' show buildDedupeKey;
import 'header_mapper.dart';

class UnparsedStatementRow {
  const UnparsedStatementRow({
    required this.rowIndex,
    required this.rawCells,
    required this.reason,
  });

  final int rowIndex;
  final List<String> rawCells;
  final String reason;

  String get rawRowJson => jsonEncode(rawCells);
}

class StatementParseResult {
  const StatementParseResult({
    required this.transactions,
    required this.unparsed,
    required this.columnMap,
    required this.skippedFooterRows,
  });

  final List<ParsedTransaction> transactions;
  final List<UnparsedStatementRow> unparsed;
  final ColumnMap columnMap;
  final int skippedFooterRows;
}

/// Grid + ColumnMap → ParsedTransaction list with continuation merging.
class StatementRowParser {
  StatementParseResult parse({
    required List<List<String>> rows,
    required ColumnMap columnMap,
    String? bankOverride,
  }) {
    final bank = bankOverride ?? columnMap.bankCode;
    final dateIdx = columnMap.indexOf(StatementField.date);
    final narrIdx = columnMap.indexOf(StatementField.narration);
    final refIdx = columnMap.indexOf(StatementField.ref);
    final debitIdx = columnMap.indexOf(StatementField.debit);
    final creditIdx = columnMap.indexOf(StatementField.credit);
    final amountIdx = columnMap.indexOf(StatementField.amount);
    final flagIdx = columnMap.indexOf(StatementField.drcrFlag);
    final balIdx = columnMap.indexOf(StatementField.balance);

    final txns = <ParsedTransaction>[];
    final unparsed = <UnparsedStatementRow>[];
    var skippedFooter = 0;

    ParsedTransaction? pending;
    var pendingNarration = '';

    void flushPending() {
      if (pending == null) return;
      final t = pending!;
      final narration = normalizeText(pendingNarration);
      final rebuilt = _withNarrationExtras(t, narration, bank);
      txns.add(rebuilt);
      pending = null;
      pendingNarration = '';
    }

    for (var i = columnMap.headerRowIndex + 1; i < rows.length; i++) {
      final row = rows[i];
      if (_isFooter(row)) {
        skippedFooter++;
        continue;
      }
      if (row.every((c) => c.trim().isEmpty)) continue;

      final dateCell = dateIdx != null ? _cell(row, dateIdx) : '';
      final hasDate = dateCell.trim().isNotEmpty;
      final debitCell = debitIdx != null ? _cell(row, debitIdx) : '';
      final creditCell = creditIdx != null ? _cell(row, creditIdx) : '';
      final amountCell = amountIdx != null ? _cell(row, amountIdx) : '';
      final hasAmount = debitCell.trim().isNotEmpty ||
          creditCell.trim().isNotEmpty ||
          amountCell.trim().isNotEmpty;

      // Continuation row: empty date & amount, narration spill.
      if (!hasDate && !hasAmount && narrIdx != null) {
        final cont = _cell(row, narrIdx).trim();
        if (cont.isNotEmpty && pending != null) {
          pendingNarration = '$pendingNarration $cont';
          continue;
        }
      }

      if (!hasDate || !hasAmount) {
        flushPending();
        unparsed.add(
          UnparsedStatementRow(
            rowIndex: i,
            rawCells: row,
            reason: !hasDate ? 'missing_date' : 'missing_amount',
          ),
        );
        continue;
      }

      flushPending();

      final bookedAt = parseStatementDate(dateCell);
      if (bookedAt == null) {
        unparsed.add(
          UnparsedStatementRow(
            rowIndex: i,
            rawCells: row,
            reason: 'bad_date',
          ),
        );
        continue;
      }

      final resolved = _resolveAmount(
        debitCell: debitCell,
        creditCell: creditCell,
        amountCell: amountCell,
        flagCell: flagIdx != null ? _cell(row, flagIdx) : '',
        narration: narrIdx != null ? _cell(row, narrIdx) : '',
      );
      if (resolved == null) {
        unparsed.add(
          UnparsedStatementRow(
            rowIndex: i,
            rawCells: row,
            reason: 'bad_amount',
          ),
        );
        continue;
      }

      final narration =
          narrIdx != null ? _cell(row, narrIdx).trim() : '';
      final refCol = refIdx != null ? _cell(row, refIdx).trim() : '';
      MoneyPaise? balance;
      if (balIdx != null) {
        balance = parseAmountCell(_cell(row, balIdx)).amount;
      }

      final type = _inferType(narration.isNotEmpty ? narration : dateCell);
      final ref = resolveStatementRef(
        refCol: refCol,
        narration: narration,
        dateCell: dateCell,
      );
      final vpa = extractVpa(narration);
      final merchant = _merchantFromNarration(narration, vpa);

      final dedupeKey = buildDedupeKey(
        bankCode: bank,
        bookedAt: bookedAt,
        amountPaise: resolved.amount.paise,
        ref: ref,
        normalizedBody: normalizeText(narration),
      );

      pending = ParsedTransaction(
        amountPaise: resolved.amount,
        direction: resolved.direction,
        type: type,
        bookedAt: bookedAt,
        bankCode: bank,
        rawMerchant: merchant,
        rawDescription: narration,
        upiPayeeVpa: vpa,
        upiRef: type == TransactionType.upi ? ref : null,
        remarks: narration,
        externalRef: ref,
        balanceAfterPaise: balance,
        dedupeKey: dedupeKey,
        directionInferred: resolved.directionInferred,
      );
      pendingNarration = narration;
    }

    flushPending();

    return StatementParseResult(
      transactions: txns,
      unparsed: unparsed,
      columnMap: columnMap,
      skippedFooterRows: skippedFooter,
    );
  }

  ParsedTransaction _withNarrationExtras(
    ParsedTransaction t,
    String narration,
    String bank,
  ) {
    final ref = resolveStatementRef(
          refCol: t.externalRef ?? '',
          narration: narration,
        ) ??
        t.externalRef;
    final vpa = extractVpa(narration) ?? t.upiPayeeVpa;
    final merchant = _merchantFromNarration(narration, vpa);
    final type = _inferType(narration);
    final dedupeKey = buildDedupeKey(
      bankCode: bank,
      bookedAt: t.bookedAt,
      amountPaise: t.amountPaise.paise,
      ref: ref,
      normalizedBody: narration,
    );
    return ParsedTransaction(
      amountPaise: t.amountPaise,
      direction: t.direction,
      type: type,
      bookedAt: t.bookedAt,
      bankCode: bank,
      accountHint: t.accountHint,
      rawMerchant: merchant,
      rawDescription: narration,
      upiPayerVpa: t.upiPayerVpa,
      upiPayeeVpa: vpa,
      upiRef: type == TransactionType.upi ? ref : null,
      remarks: narration,
      externalRef: ref,
      balanceAfterPaise: t.balanceAfterPaise,
      dedupeKey: dedupeKey,
      directionInferred: t.directionInferred,
    );
  }

  ({
    MoneyPaise amount,
    TransactionDirection direction,
    bool directionInferred,
  })? _resolveAmount({
    required String debitCell,
    required String creditCell,
    required String amountCell,
    required String flagCell,
    required String narration,
  }) {
    final debit = parseAmountCell(debitCell);
    final credit = parseAmountCell(creditCell);
    if (debit.amount != null && debit.amount!.paise > 0) {
      return (
        amount: debit.amount!,
        direction: TransactionDirection.debit,
        directionInferred: false,
      );
    }
    if (credit.amount != null && credit.amount!.paise > 0) {
      return (
        amount: credit.amount!,
        direction: TransactionDirection.credit,
        directionInferred: false,
      );
    }

    final amt = parseAmountCell(amountCell);
    if (amt.amount == null || amt.amount!.paise <= 0) return null;

    if (amt.suffixDirection != null) {
      return (
        amount: amt.amount!,
        direction: amt.suffixDirection!,
        directionInferred: false,
      );
    }

    final flag = flagCell.trim().toLowerCase();
    if (flag.startsWith('cr') || flag == 'c' || flag.contains('credit')) {
      return (
        amount: amt.amount!,
        direction: TransactionDirection.credit,
        directionInferred: false,
      );
    }
    if (flag.startsWith('dr') || flag == 'd' || flag.contains('debit')) {
      return (
        amount: amt.amount!,
        direction: TransactionDirection.debit,
        directionInferred: false,
      );
    }

    final narrDir = extractDirection(narration);
    if (narrDir != null) {
      return (
        amount: amt.amount!,
        direction: narrDir,
        directionInferred: false,
      );
    }

    return (
      amount: amt.amount!,
      direction: TransactionDirection.debit,
      directionInferred: true,
    );
  }

  TransactionType _inferType(String narration) {
    final u = narration.toUpperCase();
    if (u.contains('UPI')) return TransactionType.upi;
    if (u.contains('IMPS')) return TransactionType.imps;
    if (u.contains('NEFT')) return TransactionType.neft;
    if (u.contains('RTGS')) return TransactionType.rtgs;
    if (u.contains('ATM')) return TransactionType.atm;
    if (u.contains('POS') || u.contains('CARD')) return TransactionType.card;
    if (u.contains('SALARY')) return TransactionType.salary;
    return TransactionType.other;
  }

  String _merchantFromNarration(String narration, String? vpa) {
    if (vpa != null) return vpa;
    // UPI/xxx/MERCHANT or IMPS/.../MERCHANT
    final parts = narration.split('/');
    if (parts.length >= 3) {
      final last = parts.last.trim();
      if (last.isNotEmpty && last.length < 64) return last;
    }
    return narration.length > 48 ? narration.substring(0, 48) : narration;
  }

  bool _isFooter(List<String> row) {
    final j = row.join(' ').toLowerCase();
    return j.contains('unless the constituent') ||
        j.contains('end of statement') ||
        j.contains('total debits') ||
        j.contains('total credits') ||
        j.contains('statement summary') ||
        j.contains('this is a computer generated');
  }

  String _cell(List<String> row, int idx) =>
      idx < row.length ? row[idx] : '';
}

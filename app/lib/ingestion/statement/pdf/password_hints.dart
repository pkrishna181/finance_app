/// Per-bank password hints for encrypted statement PDFs.
///
/// Shown to help the user recall the formula their bank uses (PAN, DOB,
/// customer ID, etc.). Passwords the user chooses to remember live in
/// `PdfPasswordVault` (secure storage), never in the database.
const Map<String, String> pdfPasswordHints = {
  'AMEX': 'Try the format from your statement email (often DOB as DDMMYYYY)',
  'CAMS': 'Usually the password you set when requesting the CAS (often PAN)',
  'KFINTECH': 'Usually the password you set when requesting the CAS (often PAN)',
  'NSDL': 'Usually PAN (uppercase) + DOB as DDMMYYYY',
  'CDSL': 'Usually PAN (uppercase)',
  'HDFC': 'Try PAN (uppercase) or DOB as DDMMYYYY',
  'ICICI': 'Try date of birth as DDMMYYYY or registered mobile last 4 + DOB',
  'SBI': 'Try account number last 4 digits + DOB (DDMMYYYY)',
  'AXIS': 'Try first 4 letters of name (uppercase) + DOB (DDMMYYYY)',
  'KOTAK': 'Try CRN/customer ID or date of birth as DDMMYYYY',
  'UNKNOWN': 'Try PAN, DOB (DDMMYYYY), or customer ID from your bank email',
};

String passwordHintForBank(String? bankCode) {
  if (bankCode == null || bankCode.isEmpty) {
    return pdfPasswordHints['UNKNOWN']!;
  }
  return pdfPasswordHints[bankCode.toUpperCase()] ?? pdfPasswordHints['UNKNOWN']!;
}

import 'profile.dart';

StatementProfile genericAccountProfile() => StatementProfile(
      id: 'generic_account',
      bankCode: 'UNKNOWN',
      junkMarkers: const ['statement of account', 'opening balance'],
      headerSynonyms: genericSynonyms,
    );

import '../models/posko_location.dart';

class AuthRepository {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  final Map<String, _Account> _accounts = {
    '081234567890': const _Account(
      name: 'Koordinator Demo',
      poskoName: 'Posko Demo',
      password: 'password123',
      location: PoskoLocation.fallback,
    ),
  };

  _Account? _current;

  String? get currentPoskoName => _current?.poskoName;
  PoskoLocation get currentLocation =>
      _current?.location ?? PoskoLocation.fallback;

  bool isRegistered(String phone) => _accounts.containsKey(phone.trim());

  bool login(String phone, String password) {
    final account = _accounts[phone.trim()];
    if (account == null || account.password != password) return false;
    _current = account;
    return true;
  }

  void register({
    required String name,
    required String phone,
    required String password,
    required String poskoName,
    required PoskoLocation location,
  }) {
    _accounts[phone.trim()] = _Account(
      name: name.trim(),
      poskoName: poskoName.trim(),
      password: password,
      location: location,
    );
  }
}

class _Account {
  final String name;
  final String poskoName;
  final String password;
  final PoskoLocation location;

  const _Account({
    required this.name,
    required this.poskoName,
    required this.password,
    required this.location,
  });
}

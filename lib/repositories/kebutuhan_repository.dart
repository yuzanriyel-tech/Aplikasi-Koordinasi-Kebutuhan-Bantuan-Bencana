import '../data/dummy_data.dart';
import '../models/kebutuhan_bantuan.dart';

class KebutuhanRepository {
  Future<List<KebutuhanBantuan>> getKebutuhan() async {
    await Future<void>.delayed(const Duration(seconds: 1));

    return dummyKebutuhanBantuan;
  }
}
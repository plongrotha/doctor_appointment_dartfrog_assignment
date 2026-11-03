import 'package:doctor_appointment_api/services/crud_service.dart';
import 'package:doctor_appointment_api/services/doctor_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

class DoctorServiceImpl extends MongoCrudService implements DoctorService {
  DoctorServiceImpl(Db db)
    : super(db, 'doctors', {'userId', 'specialtyId', 'bio', 'consultationFee'});
  @override
  Future<List<Map<String, dynamic>>> getAll() => super.all();
  @override
  Future<Map<String, dynamic>?> getById(String id) => one(id);
  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) =>
      super.create(data);
  @override
  Future<Map<String, dynamic>?> update(String id, Map<String, dynamic> data) =>
      super.update(id, data);
  @override
  Future<void> delete(String id) async {
    if (!await remove(id)) throw StateError('Doctor not found');
  }
}

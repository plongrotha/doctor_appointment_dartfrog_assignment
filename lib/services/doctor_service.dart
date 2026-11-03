abstract class DoctorService {
  Future<List<Map<String, dynamic>>> getAll();
  Future<Map<String, dynamic>?> getById(String id);
  Future<Map<String, dynamic>> create(Map<String, dynamic> data);
  Future<Map<String, dynamic>?> update(String id, Map<String, dynamic> data);
  Future<void> delete(String id);
}

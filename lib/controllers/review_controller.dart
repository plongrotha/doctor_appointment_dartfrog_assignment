import 'package:doctor_appointment_api/controllers/resource_controller.dart';
import 'package:doctor_appointment_api/models/review.dart';
import 'package:doctor_appointment_api/services/auth_service.dart';
import 'package:doctor_appointment_api/services/review_service.dart';

class ReviewController extends ResourceController {
  ReviewController({required AuthService auth, required ReviewService service})
    : super(
        authService: auth,
        name: 'Review',
        list: service.getAll,
        get: service.getById,
        create: service.create,
        update: service.update,
        delete: service.delete,
        serialize: (data) => Review.fromMap(data).toJson(),
      );
}

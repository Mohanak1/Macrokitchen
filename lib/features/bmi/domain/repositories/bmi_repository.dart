import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bmi_profile.dart';

abstract class BmiRepository {
  Future<Either<Failure, BmiProfile?>> getBmiProfile(String uid);
  Future<Either<Failure, void>> saveBmiProfile(BmiProfile profile);
}

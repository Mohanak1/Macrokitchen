import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/bmi_profile_model.dart';
import '../../domain/entities/bmi_profile.dart';
import '../../domain/repositories/bmi_repository.dart';

class BmiRemoteDatasource {
  final FirebaseFirestore _firestore;

  BmiRemoteDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<BmiProfileModel?> getBmiProfile(String uid) async {
    final doc = await _firestore.collection('bmi_profiles').doc(uid).get();
    if (!doc.exists) return null;
    return BmiProfileModel.fromFirestore(doc.data()!, uid);
  }

  Future<void> saveBmiProfile(BmiProfile profile) async {
    final model = BmiProfileModel.fromEntity(profile);
    await _firestore
        .collection('bmi_profiles')
        .doc(profile.uid)
        .set(model.toFirestore(), SetOptions(merge: true));
  }
}

class BmiRepositoryImpl implements BmiRepository {
  final BmiRemoteDatasource _datasource;

  BmiRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, BmiProfile?>> getBmiProfile(String uid) async {
    try {
      final profile = await _datasource.getBmiProfile(uid);
      return Right(profile);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveBmiProfile(BmiProfile profile) async {
    try {
      await _datasource.saveBmiProfile(profile);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

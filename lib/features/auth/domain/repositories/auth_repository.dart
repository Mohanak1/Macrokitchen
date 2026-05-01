import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/app_user.dart';

abstract class AuthRepository {
  /// Stream of current auth state
  Stream<AppUser?> get authStateChanges;

  /// Current user (synchronous)
  AppUser? get currentUser;

  Future<Either<Failure, AppUser>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, AppUser>> register({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, void>> resetPassword({required String email});

  Future<Either<Failure, AppUser>> loginRestaurant({
    required String email,
    required String password,
  });
}

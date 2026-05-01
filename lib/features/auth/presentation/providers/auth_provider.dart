import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

// --- Infrastructure providers ---

final firebaseAuthDatasourceProvider = Provider<FirebaseAuthDatasource>((ref) {
  return FirebaseAuthDatasource();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(firebaseAuthDatasourceProvider));
});

// --- Auth state stream ---

final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// --- Auth notifier ---

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<String?> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    final result = await _repo.login(email: email, password: password);
    return result.fold(
      (failure) {
        state = const AsyncValue.data(null);
        return failure.message;
      },
      (_) {
        state = const AsyncValue.data(null);
        return null;
      },
    );
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    final result =
        await _repo.register(name: name, email: email, password: password);
    return result.fold(
      (failure) {
        state = const AsyncValue.data(null);
        return failure.message;
      },
      (_) {
        state = const AsyncValue.data(null);
        return null;
      },
    );
  }

  Future<String?> resetPassword({required String email}) async {
    state = const AsyncValue.loading();
    final result = await _repo.resetPassword(email: email);
    return result.fold(
      (failure) {
        state = const AsyncValue.data(null);
        return failure.message;
      },
      (_) {
        state = const AsyncValue.data(null);
        return null;
      },
    );
  }

  Future<void> logout() async {
    await _repo.logout();
  }

  Future<String?> loginRestaurant({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    final result =
        await _repo.loginRestaurant(email: email, password: password);
    return result.fold(
      (failure) {
        state = const AsyncValue.data(null);
        return failure.message;
      },
      (_) {
        state = const AsyncValue.data(null);
        return null;
      },
    );
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

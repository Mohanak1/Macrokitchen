import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/bmi_repository_impl.dart';
import '../../domain/entities/bmi_profile.dart';
import '../../domain/repositories/bmi_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final bmiDatasourceProvider = Provider((ref) => BmiRemoteDatasource());

final bmiRepositoryProvider = Provider<BmiRepository>((ref) {
  return BmiRepositoryImpl(ref.read(bmiDatasourceProvider));
});

/// Fetches current user's BMI profile
final bmiProfileProvider = FutureProvider<BmiProfile?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user == null) return null;

  final result = await ref.read(bmiRepositoryProvider).getBmiProfile(user.uid);
  return result.fold((_) => null, (profile) => profile);
});

/// Notifier for saving/updating BMI profile
class BmiNotifier extends StateNotifier<AsyncValue<void>> {
  final BmiRepository _repo;

  BmiNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<String?> save(BmiProfile profile) async {
    state = const AsyncValue.loading();
    final result = await _repo.saveBmiProfile(profile);
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

final bmiNotifierProvider =
    StateNotifierProvider<BmiNotifier, AsyncValue<void>>((ref) {
  return BmiNotifier(ref.read(bmiRepositoryProvider));
});

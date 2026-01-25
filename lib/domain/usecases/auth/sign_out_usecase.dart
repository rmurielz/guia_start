import 'package:guia_start/core/usecases/usecase.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/domain/repositories/auth_repository.dart';

class SignOutUseCase implements UseCase<void, NoParams> {
  final AuthRepository authRepository;

  SignOutUseCase(this.authRepository);

  @override
  Future<Result<void>> call(NoParams params) async {
    return await authRepository.signOut();
  }
}

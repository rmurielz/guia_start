import 'package:guia_start/core/usecases/usecase.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/domain/entities/user_profile.dart';
import 'package:guia_start/domain/repositories/auth_repository.dart';
import 'package:guia_start/domain/repositories/user_repository.dart';

class SignInUseCase implements UseCase<UserProfile, SignInParams> {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  SignInUseCase({
    required this.authRepository,
    required this.userRepository,
  });

  @override
  Future<Result<UserProfile>> call(SignInParams params) async {
    // 1. Autenticar con Firebase
    final authResult = await authRepository.signIn(
      email: params.email,
      password: params.password,
    );

    if (authResult.isError) {
      return Result.failure(authResult.failure!);
    }

    final userId = authResult.data!;

    // 2. Obtener perfil del usuario
    final profileResult = await userRepository.getById(userId);

    if (profileResult.isError) {
      return Result.failure(profileResult.failure!);
    }

    return Result.success(profileResult.data!);
  }
}

class SignInParams {
  final String email;
  final String password;

  SignInParams({
    required this.email,
    required this.password,
  });
}

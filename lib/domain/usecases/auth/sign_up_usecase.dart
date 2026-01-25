import 'package:guia_start/core/error/failures.dart';
import 'package:guia_start/core/usecases/usecase.dart';
import 'package:guia_start/core/utils/result.dart';
import 'package:guia_start/domain/entities/user_profile.dart';
import 'package:guia_start/domain/repositories/auth_repository.dart';
import 'package:guia_start/domain/repositories/user_repository.dart';

class SignUpUseCase implements UseCase<UserProfile, SignUpParams> {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  SignUpUseCase({
    required this.authRepository,
    required this.userRepository,
  });

  @override
  Future<Result<UserProfile>> call(SignUpParams params) async {
    // 1. Registrar en Firebase Auth
    final authResult = await authRepository.signUp(
      email: params.email,
      password: params.password,
      name: params.name,
      businessName: params.businessName,
    );

    if (authResult.isError) {
      return Result.failure(authResult.failure!);
    }

    final userId = authResult.data!;

    // 2. Crear perfil en Firestore
    final profile = UserProfile(
        id: userId,
        email: params.email,
        name: params.name,
        businessName: params.businessName,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now());

    final createResult = await userRepository.create(profile);

    if (createResult.isError) {
      // Si falla crear el perfil, intentar eliminar el usuario de Auth
      await authRepository.signOut();
      return Result.failure(
        const ServerFailure('Error al crear perfil de usuario'),
      );
    }

    return Result.success(createResult.data!);
  }
}

class SignUpParams {
  final String email;
  final String password;
  final String name;
  final String? businessName;

  SignUpParams({
    required this.email,
    required this.password,
    required this.name,
    this.businessName,
  });
}

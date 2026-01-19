import 'package:guia_start/core/utils/result.dart';

/// Interfaz base para todos los casos de uso
///
/// [Type] es el tipo de dato que retorna
/// [Params] son los parámetros que recibe

abstract class UseCase<Type, Params> {
  Future<Result<Type>> call(Params params);
}

/// Para casos de uso su parámetros
class NoParams {
  const NoParams();
}

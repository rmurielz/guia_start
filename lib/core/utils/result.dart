import 'package:guia_start/core/error/failures.dart';

/// Representa el resultado de una operación que puede fallar

class Result<T> {
  final T? data;
  final Failure? failure;
  final ResultStatus status;

  Result._({this.data, this.failure, required this.status});

  factory Result.success(T data) {
    return Result._(data: data, status: ResultStatus.success);
  }

  factory Result.failure(Failure failure) {
    return Result._(failure: failure, status: ResultStatus.error);
  }

  /// Mantener compatibilidad con código actual (eliminar después)
  @Deprecated('Use Result.failure() instead')
  factory Result.error(String message) {
    return Result._(
      failure: ServerFailure(message),
      status: ResultStatus.error,
    );
  }

  bool get isSuccess => status == ResultStatus.success;
  bool get isError => status == ResultStatus.error;

  // Helper para obtener mensaje de error
  String? get error => failure?.message;
}

enum ResultStatus { success, error }

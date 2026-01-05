/// Representa el resultado de una operación que puede fallar
///
/// Uso:
/// ´´´dart
/// final result = await repo.save();
/// if (result.isSuccess){
/// print(result.data);
/// } else {
/// print(result.error);
/// }
/// ´´´
class Result<T> {
  final T? data;
  final String? error;
  final ResultStatus status;

  Result._({this.data, this.error, required this.status});

  factory Result.success(T data) {
    return Result._(data: data, status: ResultStatus.success);
  }

  factory Result.error(String message) {
    return Result._(error: message, status: ResultStatus.error);
  }

  bool get isSuccess => status == ResultStatus.success;
  bool get isError => status == ResultStatus.error;
}

enum ResultStatus { success, error }

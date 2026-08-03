/// Lightweight Result type for fallible operations without exceptions.
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  T? get okOrNull => switch (this) {
        Ok(:final value) => value,
        Err() => null,
      };

  String? get errorOrNull => switch (this) {
        Ok() => null,
        Err(:final message) => message,
      };

  R when<R>({
    required R Function(T value) ok,
    required R Function(String message, Object? cause) err,
  }) {
    return switch (this) {
      Ok(:final value) => ok(value),
      Err(:final message, :final cause) => err(message, cause),
    };
  }
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.message, [this.cause]);
  final String message;
  final Object? cause;
}

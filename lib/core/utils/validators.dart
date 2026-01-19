/// Utilidades para validación de formularios.
///
/// Uso:
/// '''dart
/// textFormField(
///   validator: Validators.comppose([
///     Validators.required('Este campo es obligatorio'),
///     Validators.minLength(3, 'Mínimo 3 caracteres'),
///   ]),
/// )
/// '''
library;

class Validators {
  /// Valida que el campo no esté vacío.
  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) {
          return error;
        }
      }
      return null;
    };
  }

  /// Valida que el campo no esté vacío.
  static String? Function(String?) required([String? message]) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return message ?? 'Este campo es obligatorio';
      }
      return null;
    };
  }

  /// Valida que el campo tenga una longitud mínima.
  static String? Function(String?) minLength(int min, [String? message]) {
    return (String? value) {
      if (value == null || value.isEmpty) return null; // Skip if empty
      if (value.trim().length < min) {
        return message ?? 'Mínimo $min caracteres';
      }
      return null;
    };
  }

  /// Valida que el campo tenga una longitud máxima.
  static String? Function(String?) maxLength(int max, [String? message]) {
    return (String? value) {
      if (value == null || value.isEmpty) return null; // Skip if empty
      if (value.trim().length > max) {
        return message ?? 'Máximo $max caracteres';
      }
      return null;
    };
  }

  /// Valida formato de email.
  static String? Function(String?) email([String? message]) {
    return (String? value) {
      if (value == null || value.isEmpty) return null; // Skip if empty
      final emailRegex = RegExp(
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$',
      );
      if (!emailRegex.hasMatch(value)) {
        return message ?? 'Formato de email inválido';
      }
      return null;
    };
  }

  /// Valida que el campo sea un número.
  static String? Function(String?) numeric([String? message]) {
    return (String? value) {
      if (value == null || value.isEmpty) return null; // Skip if empty
      if (double.tryParse(value) == null) {
        return message ?? 'Debe ser un número válido';
      }
      return null;
    };
  }

  /// Valida el valor mínimo (para números).
  static String? Function(String?) min(double min, [String? message]) {
    return (String? value) {
      if (value == null || value.isEmpty) return null; // Skip if empty

      final number = double.tryParse(value);
      if (number == null) return null; // Skip if not a number

      if (number < min) {
        return message ?? 'El valor debe ser al menos $min';
      }
      return null;
    };
  }

  /// Valida el valor máximo (para números).
  static String? Function(String?) max(double max, [String? message]) {
    return (String? value) {
      if (value == null || value.isEmpty) return null; // Skip if empty

      final number = double.tryParse(value);
      if (number == null) return null; // Skip if not a number

      if (number > max) {
        return message ?? 'El valor debe ser como máximo $max';
      }
      return null;
    };
  }

  /// Valida que coincida con un patrón regex.
  static String? Function(String?) pattern(RegExp regex, [String? message]) {
    return (String? value) {
      if (value == null || value.isEmpty) return null; // Skip if empty

      if (!regex.hasMatch(value)) {
        return message;
      }
      return null;
    };
  }

  /// Valida que dos campos coincidan (útil para confirmación de contraseñas).
  static String? Function(String?) match(
    String otherValue,
    String fieldName,
  ) {
    return (String? value) {
      if (value == null || value.isEmpty) return null; // Skip if empty

      if (value != otherValue) {
        return 'El valor debe coincidir con $fieldName';
      }
      return null;
    };
  }
}

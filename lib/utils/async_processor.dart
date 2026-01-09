import 'package:flutter/material.dart';
import 'package:guia_start/utils/result.dart';

mixin AsyncProcessor<T extends StatefulWidget> on State<T> {
  bool isProcessing = false;

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> executeOperation<R>({
    required Future<Result<R>> operation,
    required String successMessage,
    VoidCallback? onSuccess,
    bool showSuccessMessage = true,
  }) async {
    setState(() => isProcessing = true);
    final result = await operation;

    if (!mounted) return;

    setState(() => isProcessing = false);

    if (result.isError) {
      _showSnackBar(result.error!, isError: true);
    } else {
      if (showSuccessMessage) {
        _showSnackBar(successMessage);
      }
      if (onSuccess != null) {
        onSuccess();
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:stylish_dialog/stylish_dialog.dart';

showError(BuildContext context, String errorMessage) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline_outlined,
                  color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 8),
              const Text('Error'),
            ],
          ),
          content: Text(toSentenceCase(errorMessage)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      });
}

showProgressDialog(BuildContext context) {
  StylishDialog dialog = StylishDialog(
    context: context,
    alertType: StylishDialogType.PROGRESS,
    dismissOnTouchOutside: false,
    title: const Text(
      'Loading',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color.fromRGBO(46, 46, 46, 1),
      ),
    ),
    content: const Text(
      "Please wait ...",
      style: TextStyle(
        color: Color.fromRGBO(46, 46, 46, 1),
      ),
      textAlign: TextAlign.center,
    ),
  );
  return dialog;
}

String toSentenceCase(String input) {
  if (input.isEmpty) return input;

  input = input.trim();

  // Capitalize the first letter of the string
  String result = input[0].toUpperCase() + input.substring(1).toLowerCase();

  // Find all occurrences of ". " and capitalize the next character
  for (int i = 0; i < result.length - 1; i++) {
    if (result[i] == '.' && result[i + 1] == ' ') {
      if (i + 2 < result.length) {
        result = result.substring(0, i + 2) +
            result[i + 2].toUpperCase() +
            result.substring(i + 3);
      }
    }
  }

  return result;
}

StylishDialog showSuccessDialog(BuildContext context, String message) {
  StylishDialog dialog = StylishDialog(
    context: context,
    alertType: StylishDialogType.SUCCESS,
    dismissOnTouchOutside: true,
    title: const Text(
      'Success',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color.fromRGBO(46, 46, 46, 1),
      ),
    ),
    content: Text(
      message,
      style: const TextStyle(
        color: Color.fromRGBO(46, 46, 46, 1),
      ),
      textAlign: TextAlign.center,
    ),
    confirmButton: Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('Ok'),
      ),
    ),
  );
  return dialog;
  // AwesomeDialog(context: context,);
}

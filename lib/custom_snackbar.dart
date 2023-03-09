import 'package:flutter/material.dart';

SnackBar getMySnackbar(BuildContext context, String text) {
  return SnackBar(
    backgroundColor: Color.fromARGB(91, 0, 85, 255),
    content: Text(text,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
    duration: const Duration(seconds: 2),
  );
}

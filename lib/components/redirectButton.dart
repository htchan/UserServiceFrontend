import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RedirectButton extends StatelessWidget {
  final String text;
  final String redirectPath;

  const RedirectButton(this.text, this.redirectPath);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          redirectPath
        );
      },
      child: Text(text)
    );
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../../../utils/constants/text_strings.dart';

class RememberMe extends StatefulWidget {
  const RememberMe({super.key, required this.valueChanged});
  final ValueChanged<bool> valueChanged;

  @override
  State<RememberMe> createState() => _RememberMeState();
}

class _RememberMeState extends State<RememberMe> {
  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: rememberMe,
          onChanged: (value) {
            rememberMe = value ?? false;
            widget.valueChanged(value ?? false);
            setState(() {});
          },
        ),
        const Text(AppTexts.rememberMe),
      ],
    );
  }
}
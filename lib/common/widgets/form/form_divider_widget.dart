import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/helpers/helper_functions.dart';

class FormDividerWidget extends StatelessWidget {
  const FormDividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    return Row(
      children: [
        Flexible(
          child: Divider(
            thickness: 1,
            indent: 50,
            color: Colors.grey.withValues(alpha: 0.3),
            endIndent: 10,
          ),
        ),
        Text(
          AppTexts.or,
          style: Theme.of(context).textTheme.bodyLarge!.apply(
            color: dark
                ? AppColors.white.withValues(alpha: 0.5)
                : AppColors.dark.withValues(alpha: 0.5),
          ),
        ),
        Flexible(
          child: Divider(
            thickness: 1,
            indent: 10,
            color: Colors.grey.withValues(alpha: 0.3),
            endIndent: 50,
          ),
        ),
      ],
    );
  }
}

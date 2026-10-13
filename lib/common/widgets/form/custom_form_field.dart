
import 'package:flutter/material.dart';

class CustomFormfieldWidget extends StatefulWidget {

  CustomFormfieldWidget(
      {super.key, required this.label, required this.withdownEar,
        required this.controller, required this.validator, this.prefixIcon,
      });
  final String label;
   final bool withdownEar;
  final TextEditingController controller;
  final Function(String?) validator;
  final Widget? prefixIcon;
  CustomFormfieldWidget.withdownEar({
    required this.label,

    required this.controller,
    required this.validator,
      this.prefixIcon
  }) : withdownEar = true;

  @override
  State<CustomFormfieldWidget> createState() => _CustomFormfieldWidgetState();
}

class _CustomFormfieldWidgetState extends State<CustomFormfieldWidget> {
  bool isVisible = true;

  bool obScureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         TextFormField(
          validator:(value)=>widget.validator(value),
          controller: widget.controller,
          obscureText:widget.withdownEar == false ? obScureText : false,
          style: TextStyle(
            color: Color(0xFF363636),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            label: Text(widget.label),
               suffixIcon: widget.withdownEar == true ? null : IconButton(
                onPressed: (){
                  setState(() {
                    isVisible = !isVisible;
                    obScureText = !obScureText;
                  });
                },
                icon: !isVisible ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
              ),
              prefixIcon: widget.prefixIcon,
          ),),
      ],
    );
  }
}
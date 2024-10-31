import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      this.labelText,
      this.obscureText = false,
      this.suffixIcon,
      this.onChanged,
      this.validator,
      this.keyboardType});
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final void Function(String)? onChanged;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  @override
  State<StatefulWidget> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      autofocus: false,
      obscureText: widget.obscureText,
      onChanged: widget.onChanged,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      style: const TextStyle(
        fontSize: 14,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color.fromRGBO(249, 249, 249, 1),
        label: widget.labelText != null
            ? Text(
                widget.labelText!,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 64, 71, 21),
                ),
              )
            : null,
        hintText: widget.hintText,
        hintStyle: const TextStyle(
            fontSize: 13,
            color: Color.fromRGBO(204, 204, 204, 1),
            fontWeight: FontWeight.normal),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide:  BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width:0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary, width: 2.0,),
        ),
        suffixIcon: widget.suffixIcon,
      ),
    );
  }
}

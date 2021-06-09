import 'package:flutter/material.dart';

class InputField extends StatelessWidget {

  final IconData icon;
  final String hint;
  final bool obscure;
  final String label;
  final Stream<String> stream;
  final Function(String) onChanged;

  InputField({this.icon, this.hint, this.obscure, this.label, this.stream,
    this.onChanged}) ;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
        stream: stream,
        builder: (context, snapshot) {
          return TextField(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(
                  left: 5, right: 30, bottom: 30, top: 30),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.pinkAccent)
              ),
              icon: Icon(icon, color: Colors.white),
              hintStyle: TextStyle(color: Colors.white),
              hintText: hint,
              labelStyle: TextStyle(color: Colors.white),
              labelText: label,
              errorText: snapshot.hasError ? snapshot.error : null,
            ),
            obscureText: obscure,
            onChanged: onChanged,
            style: TextStyle(color: Colors.white),
          );
        }
    );
  }
}
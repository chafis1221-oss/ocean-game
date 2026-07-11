// custom_button.dart - Tombol reusable

import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutlined;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              child: Text(text, style: TextStyle(fontSize: 16, color: Colors.white)),
              style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white)),
            )
          : ElevatedButton(
              onPressed: onPressed,
              child: Text(text, style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
            ),
    );
  }
}

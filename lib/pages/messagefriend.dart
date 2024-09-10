import 'package:flutter/material.dart';

class messagefriend extends StatelessWidget {
  final String message;

  const messagefriend({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft, // توجيه الفقاعة لليسار
      child: Container(
        padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16, right: 16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
          color: Color(0xFFD7850B),
        ),
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.white, // لون النص أبيض
            fontSize: 16, // حجم الخط
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Ocupar todo el espacio horizontal disponible
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(
                255, 12, 156, 31), // Color de fondo del botón (índigo)
          ),
          child: Text(
            text,
            style: TextStyle(color: Colors.white), // Color del texto (blanco)
          ),
        ),
      ),
    );
  }
}

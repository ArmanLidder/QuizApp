import 'package:flutter/material.dart';

class ThemeColorOption extends StatelessWidget {
  final Color color;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  // Constructor to pass required parameters
  ThemeColorOption({
    required this.color,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,  // When tapped, call onTap callback
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circle that shows the color
          CircleAvatar(
            backgroundColor: color,  // Set the background color to the passed color
            radius: 32,  // Set radius for the circle
            child: isSelected  // If selected, show a check icon inside the circle
                ? Icon(
              Icons.check,
              color: Colors.white,
              size: 20,
            )
                : null,
          ),
          SizedBox(height: 8),  // Space between circle and label
          // Label under the circle
          Text(
            label,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

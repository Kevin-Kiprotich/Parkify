import 'package:flutter/material.dart';

class BasemapButton extends StatefulWidget {
  const BasemapButton({
    super.key,
    required this.activeColor,
    required this.isActive,
    required this.mapType,
    required this.onPressed,
    required this.image,
  });
  final Color activeColor;
  final bool isActive;
  final String mapType;
  final Image image;
  final void Function() onPressed;
  @override
  State<BasemapButton> createState() => _BasemapButtonState();
}

class _BasemapButtonState extends State<BasemapButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: widget.isActive
                  ? Border.all(width: 1.5, color: widget.activeColor)
                  : const Border(
                      bottom: BorderSide.none,
                      top: BorderSide.none,
                      left: BorderSide.none,
                      right: BorderSide.none,
                      ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: widget.image,
            ),
          ),
          Text(
            widget.mapType,
            style: TextStyle(
              fontSize: 12,
              color: !widget.isActive ? Colors.grey[700] : widget.activeColor,
            ),
          ),
        ],
      ),
    );
  }
}

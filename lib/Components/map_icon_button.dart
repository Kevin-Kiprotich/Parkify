import 'package:flutter/material.dart';

enum Pos { top, center, bottom }

class MapIconButton extends StatefulWidget {
  const MapIconButton(
      {super.key, this.position, required this.onPressed, required this.icon});
  final Pos? position;
  final VoidCallback onPressed;
  final Widget icon;
  @override
  State<MapIconButton> createState() => _MapIconButtonState();
}

class _MapIconButtonState extends State<MapIconButton> {
  final Color _borderColor = const Color.fromARGB(255, 168, 180, 190);

  @override
  Widget build(BuildContext context) {
    final BorderSide borderSide = BorderSide(color: _borderColor, width: 1.0);
    return Container(
      height: 45,
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.7),
            spreadRadius: 0.5,
            blurRadius: 0.5,  
            offset: const Offset(0.5, 1.5),
          )
        ],
        color: Colors.white,
        border: widget.position == Pos.center
            ? Border(
                top: borderSide,
                left: borderSide,
                right: borderSide,
              )
            : widget.position == Pos.top
                ? BorderDirectional(
                    top: borderSide, start: borderSide, end: borderSide)
                : BorderDirectional(
                    top: borderSide,
                    bottom: borderSide,
                    start: borderSide,
                    end: borderSide),
        borderRadius: widget.position == Pos.top
            ? const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              )
            : widget.position == Pos.bottom
                ? const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  )
                : BorderRadius.circular(23),
      ),
      child: Center(
        child: IconButton(
          onPressed: widget.onPressed,
          icon: widget.icon,
          iconSize: 40,
        ),
      ),
    );
  }
}

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart'; // Ensures Key is available

class BottomnavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomnavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  State<BottomnavBar> createState() => _BottomnavBarState();
}

class _BottomnavBarState extends State<BottomnavBar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CurvedNavigationBar(
        index: widget.currentIndex,
        height: 60.0,
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        items: const <Widget>[
          Icon(Icons.home, size: 30),
          Icon(Icons.pets, size: 30),
          Icon(Icons.chat, size: 30),
          Icon(Icons.settings, size: 30),
        ],
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: widget.onTap,
      ),
    );
  }
}

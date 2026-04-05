import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrientationBar extends StatefulWidget {
  const OrientationBar({super.key});
  @override
  State<OrientationBar> createState() => _OrientationBarState();
}

class _OrientationBarState extends State<OrientationBar> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(minutes: 1),
        (_) => setState(() => _now = DateTime.now()));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _dayPeriod {
    final h = _now.hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1A237E),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${DateFormat('EEEE').format(_now)} $_dayPeriod',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold),
          ),
          Text(
            DateFormat('h:mm a').format(_now),
            style: const TextStyle(color: Colors.white70, fontSize: 20),
          ),
        ],
      ),
    );
  }
}
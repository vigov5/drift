import 'package:flutter/material.dart';

class BroadcastStatusIcon extends StatefulWidget {
  const BroadcastStatusIcon({super.key, required this.active, this.size = 20});

  final bool active;
  final double size;

  @override
  State<BroadcastStatusIcon> createState() => _BroadcastStatusIconState();
}

class _BroadcastStatusIconState extends State<BroadcastStatusIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 0.35,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF49B36C);
    const inactiveColor = Color(0xFFBBBBBB);

    return Tooltip(
      message: widget.active ? 'Broadcasting' : 'Not broadcasting',
      child: SizedBox(
        width: widget.size + 18,
        height: widget.size + 18,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: widget.active
                ? FadeTransition(
                    key: const ValueKey<String>('broadcast-on'),
                    opacity: _pulse,
                    child: Icon(
                      Icons.sensors_rounded,
                      size: widget.size,
                      color: activeColor,
                    ),
                  )
                : Icon(
                    key: const ValueKey<String>('broadcast-off'),
                    Icons.sensors_off_rounded,
                    size: widget.size,
                    color: inactiveColor,
                  ),
          ),
        ),
      ),
    );
  }
}

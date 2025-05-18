import 'dart:math';
import 'dart:async'; // For Timer

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomLoadingScreen extends StatefulWidget {
  final Duration duration; // Controls how long the loading screen is shown

  const CustomLoadingScreen({
    super.key,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<CustomLoadingScreen> createState() => _CustomLoadingScreenState();
}

class _CustomLoadingScreenState extends State<CustomLoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _pulseController;

  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.9,
      upperBound: 1.1,
    )..repeat(reverse: true);

    // Start the timer
    _timer = Timer(widget.duration, () {
      // You can do something here if needed later
      // Like setting a flag or notifying parent
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _timer.cancel(); // Cancel timer when widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.3;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationController.value * 6.28,
              child: child,
            );
          },
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                for (int i = 0; i < 8; i++)
                  _buildOrbitDot(
                    angle: i * 45.0,
                    radius: size / 2.2,
                    color: Colors.primaries[i % Colors.primaries.length],
                  ),
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseController.value,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withAlpha(128),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrbitDot({
    required double angle,
    required double radius,
    required Color color,
  }) {
    final rad = angle * pi / 180;
    return Positioned(
      left: radius + radius * cos(rad),
      top: radius + radius * sin(rad),
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class BareBonesLoadingIndicator {
  final BuildContext _context;

  void hide() {
    _context.pop();
  }

  void show() {
    showDialog(
      context: _context,
      barrierDismissible: false,
      useSafeArea: false,
      builder: (_) => const LoadingIndicator(),
    );
  }

  BareBonesLoadingIndicator._create(this._context);

  factory BareBonesLoadingIndicator.of(BuildContext context) {
    return BareBonesLoadingIndicator._create(context);
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.1)),
      child: Center(
        child: Stack(
          children: [
            Align(child: SizedBox(height: size.height, width: size.width)),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}

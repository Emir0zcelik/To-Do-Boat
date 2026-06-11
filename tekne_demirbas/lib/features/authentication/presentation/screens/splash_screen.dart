import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ancyra_sailing/utils/appstyles.dart';
import 'package:ancyra_sailing/utils/size_config.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _waveAnimation = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(
        parent: _waveController,
        curve: Curves.linear,
      ),
    );

    Timer(const Duration(milliseconds: 2500), () {
      _navigateToNextScreen();
    });
  }

  void _navigateToNextScreen() {
    final firebaseAuth = FirebaseAuth.instance;
    final isLoggedIn = firebaseAuth.currentUser != null;
    final isEmailVerified = firebaseAuth.currentUser?.emailVerified ?? false;

    if (mounted) {
      if (isLoggedIn && isEmailVerified) {
        context.go('/roomSelection');
      } else {
        context.go('/signIn');
      }
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: Appstyles.oceanGradient,
        ),
        child: Stack(
          children: [
            // Dalga animasyonu
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _waveAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: WavePainter(_waveAnimation.value),
                  );
                },
              ),
            ),

            // Logo ve başlık
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: Appstyles.strongShadow,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/icon/Ancyra_icon.png',
                        width: 112,
                        height: 112,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Ancyra Sailing',
                    style: Appstyles.headingTextStyle.copyWith(
                      color: Colors.white,
                      fontSize: SizeConfig.getProportionateHeight(28),
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dalga çizimi için CustomPainter
class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = 30.0;
    final waveLength = size.width / 2;

    // İlk dalga
    path.moveTo(0, size.height * 0.7);
    for (double x = 0; x <= size.width; x++) {
      final y = size.height * 0.7 +
          waveHeight *
              math.sin((x / waveLength + animationValue * 2 * math.pi) * 2 * math.pi);
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);

    // İkinci dalga (daha küçük)
    final path2 = Path();
    path2.moveTo(0, size.height * 0.75);
    for (double x = 0; x <= size.width; x++) {
      final y = size.height * 0.75 +
          waveHeight *
              0.6 *
              math.sin((x / waveLength * 1.5 - animationValue * 2 * math.pi) * 2 * math.pi);
      path2.lineTo(x, y);
    }
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

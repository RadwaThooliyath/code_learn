import 'package:uptrail/app_constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Setup animations
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    // Start logo animation
    _logoController.forward();

    // Wait a bit, then start text animation
    await Future.delayed(const Duration(milliseconds: 300));
    _textController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration:  BoxDecoration(
          color: AppColors.white,

        ),
        child: Stack(
          children: [
            // Background SVG at bottom

            // Main content
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated SVG Logo
                    AnimatedBuilder(
                      animation: _logoAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoAnimation.value,
                          child: SvgPicture.asset(
                            'assets/logo/logo.svg',
                            width: 100,
                            height: 100,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    // Animated Text
                    AnimatedBuilder(
                      animation: _textAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _textAnimation.value,
                          child: Transform.translate(
                            offset: Offset(0, 30 * (1 - _textAnimation.value)),
                            child: Column(
                              children: [

                                const Text(
                                  "Learn. Grow. Succeed.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 48),
                                const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.black
                                  ),
                                  strokeWidth: 3,
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
          ],
        ),
      ),
    );
  }
}

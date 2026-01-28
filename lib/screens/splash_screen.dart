import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onGetStarted;
  final bool autoNavigate;
  final Duration autoNavigateDuration;

  const SplashScreen({
    super.key,
    required this.onGetStarted,
    this.autoNavigate = false,
    this.autoNavigateDuration = const Duration(seconds: 3),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _logoScaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeIn),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();

    if (widget.autoNavigate) {
      Future.delayed(widget.autoNavigateDuration, () {
        if (mounted) {
          _controller.reverse().then((_) => widget.onGetStarted());
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101622),
      body: Stack(
        children: [
          // Animated Background Decor
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF256af4).withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4],
                  center: const Alignment(0.2, 0.3),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF256af4).withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4],
                  center: const Alignment(0.8, 0.7),
                ),
              ),
            ),
          ),

          // Main Content
          ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Section
                      _buildLogoSection(),
                      const SizedBox(height: 40),

                      // Header Text
                      _buildHeaderText(),
                      const SizedBox(height: 80),

                      // Get Started Button
                      _buildGetStartedButton(),
                      const SizedBox(height: 24),

                      // App Version / Secondary Info
                      _buildVersionText(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Background Imagery for Depth
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [const Color(0xFF101622), Colors.transparent],
                ),
              ),
              child: Image.network(
                'https://images.unsplash.com/photo-1518709268805-4e9042af2176?q=80&w=2068&auto=format&fit=crop',
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return ScaleTransition(
      scale: _logoScaleAnimation,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Decorative Orbit Ring
          Container(
            width: 164,
            height: 164,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF256af4).withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(0xFF256af4)),
              strokeWidth: 1,
              value: 0.3,
            ),
          ),

          // Glass Logo Container
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.03),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF256af4).withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              Icons.local_gas_station,
              color: Color(0xFF256af4),
              size: 64,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderText() {
    return Column(
      children: [
        // Welcome Text
        Text(
          'Welcome',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 42,
            fontWeight: FontWeight.w800,
            height: 1.0,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),

        // Subtitle
        Text(
          'Fueling your journey, connecting your drive.',
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 18,
            fontWeight: FontWeight.normal,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildGetStartedButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Add button press animation
          _controller.reverse().then((_) {
            widget.onGetStarted();
          });
        },
        style:
            ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF256af4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              elevation: 0,
              shadowColor: const Color(0xFF256af4).withValues(alpha: 0.4),
              surfaceTintColor: Colors.transparent,
            ).copyWith(
              overlayColor: MaterialStateProperty.resolveWith<Color?>((
                Set<MaterialState> states,
              ) {
                if (states.contains(MaterialState.pressed)) {
                  return Colors.white.withValues(alpha: 0.2);
                }
                return null;
              }),
            ),
        child: Text(
          'Get Started',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildVersionText() {
    return Text(
      'Premium Car Union Service',
      style: GoogleFonts.inter(
        color: Colors.white.withValues(alpha: 0.3),
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 2.0,
      ),
    );
  }
}





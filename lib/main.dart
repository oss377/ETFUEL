import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/station_registration_screen.dart';
import 'screens/vehicle_registration_screen.dart';
import 'screens/station_owner.dart';
import 'screens/car_owner.dart';
import 'screens/home_page.dart'; // Add this import for station home
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Error initializing Firebase: $e');
  }

  runApp(const ETFUELApp());
}

class ETFUELApp extends StatelessWidget {
  const ETFUELApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ETFUEL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF256af4),
        scaffoldBackgroundColor: const Color(0xFF0a0c10),
        fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0a0c10),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF256af4),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.dark,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = true;
  AppState _appState = AppState.splash;
  String _userName = '';
  String _userRole = '';
  int _landingTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      // Start with splash screen
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // Check if user is already logged in
      final user = _auth.currentUser;
      
      if (user != null) {
        // User is logged in, get their role
        await _fetchUserRole(user.uid);
      } else {
        // No user logged in, go to splash then landing
        setState(() {
          _isLoading = false;
          _appState = AppState.splash;
        });
      }
    } catch (e) {
      print('Error checking auth state: $e');
      setState(() {
        _isLoading = false;
        _appState = AppState.splash;
      });
    }
  }

  Future<void> _fetchUserRole(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final role = data['role']?.toString().toLowerCase() ?? 'driver';
        final fullName = data['fullName']?.toString() ?? 'User';
        
        setState(() {
          _isLoading = false;
          _userName = fullName;
          _userRole = role;
          
          // Navigate based on role
          if (role == 'driver') {
            _appState = AppState.landing; // Driver goes to LandingScreen
          } else if (role == 'station') {
            _appState = AppState.stationHomePage; // Station goes to HomePage
          } else {
            // Unknown role, go to login
            _appState = AppState.login;
          }
        });
      } else {
        // User document doesn't exist, go to login
        await _auth.signOut();
        setState(() {
          _isLoading = false;
          _appState = AppState.login;
        });
      }
    } catch (e) {
      print('Error fetching user role: $e');
      setState(() {
        _isLoading = false;
        _appState = AppState.login;
      });
    }
  }

  void _handleSplashComplete() {
    setState(() {
      _appState = AppState.landing;
    });
  }

  void _handleLoginSuccess() {
    // After login, check auth state again to get user role
    _checkAuthState();
  }

  void _handleLogout() async {
    await _auth.signOut();
    setState(() {
      _userName = '';
      _userRole = '';
      _appState = AppState.landing;
    });
  }

  void _handleBackToLogin() {
    setState(() {
      _appState = AppState.login;
    });
  }

  void _handleGoToLanding() {
    setState(() {
      _appState = AppState.landing;
    });
  }

  void _handleRegisterVehicle() {
    setState(() {
      _appState = AppState.vehicleRegistration;
    });
  }

  void _handleRegisterStation() {
    setState(() {
      _appState = AppState.stationRegistration;
    });
  }

  void _handleLandingTabChange(int index) {
    setState(() {
      _landingTabIndex = index;
    });
  }

  void _handleLandingNavigation(String route) {
    switch (route) {
      case 'register_vehicle':
        _handleRegisterVehicle();
        break;
      case 'map':
        _handleLandingTabChange(1);
        break;
    }
  }

  Widget _buildCurrentScreen() {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0a0c10),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF256af4)),
              const SizedBox(height: 20),
              Text(
                'Checking Authentication...',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    switch (_appState) {
      case AppState.splash:
        return SplashScreen(
          autoNavigate: true,
          autoNavigateDuration: const Duration(seconds: 2),
          onGetStarted: _handleSplashComplete,
        );

      case AppState.landing:
        return LandingScreen(
          onLogin: () {
            setState(() {
              _appState = AppState.login;
            });
          },
          onLogout: _handleLogout,
          onRegisterVehicle: _handleRegisterVehicle,
          currentTabIndex: _landingTabIndex,
          onTabChanged: _handleLandingTabChange,
          onNavigate: _handleLandingNavigation,
          onRegisterAsDriver: _handleRegisterVehicle,
          onRegisterAsStationOwner: _handleRegisterStation,
          onRegisterStation: _handleRegisterStation,
        );

      case AppState.login:
        return LoginScreen(
          onLoginSuccess: _handleLoginSuccess,
          onBackPressed: _handleGoToLanding,
          onRegisterAsDriver: _handleRegisterVehicle,
          onRegisterAsStationOwner: _handleRegisterStation,
        );

      case AppState.vehicleRegistration:
        return VehicleRegistrationScreen(
          onBackPressed: _handleGoToLanding,
          onCreateAccount: _handleLoginSuccess,
        );

      case AppState.stationRegistration:
        return StationRegistrationScreen(
          onBackPressed: _handleGoToLanding,
          onRegistrationComplete: _handleLoginSuccess,
        );

      case AppState.carOwnerHome:
        return CarOwnerHome(
          userName: _userName,
          onLogout: _handleLogout,
        );

      case AppState.stationOwnerDashboard:
        return StationOwnerDashboard(
          userName: _userName,
          onLogout: _handleLogout,
        );

      case AppState.stationHomePage:
        return HomePage(
          userName: _userName,
          onLogout: _handleLogout,
        );

      default:
        return SplashScreen(
          autoNavigate: true,
          autoNavigateDuration: const Duration(seconds: 2),
          onGetStarted: _handleSplashComplete,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _buildCurrentScreen(),
    );
  }
}

enum AppState {
  splash,
  landing,
  login,
  carOwnerHome,
  stationOwnerDashboard,
  stationHomePage, // Added this for station home
  vehicleRegistration,
  stationRegistration,
}
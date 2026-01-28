import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class VehicleRegistrationScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onSkip;
  final VoidCallback onCreateAccount;

  const VehicleRegistrationScreen({
    super.key,
    this.onBackPressed,
    this.onSkip,
    required this.onCreateAccount,
  });

  @override
  State<VehicleRegistrationScreen> createState() =>
      _VehicleRegistrationScreenState();
}

class _VehicleRegistrationScreenState extends State<VehicleRegistrationScreen> {
  // Form Controllers
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();

  // Driver Details Controllers
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _driverEmailController = TextEditingController();
  final TextEditingController _driverPhoneController = TextEditingController();
  final TextEditingController _driverLicenseController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Location Controller
  final TextEditingController _locationController = TextEditingController();

  // Form State
  String _selectedFuelType = 'Electric';
  bool _isMembershipEnabled = true;
  String _selectedTier = 'Racer Pro';
  String _selectedVehicleType = 'Car';
  bool _isLoading = false;

  // Password visibility
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  // Location variables
  double? _latitude;
  double? _longitude;
  String _address = '';
  Position? _currentPosition;
  LocationPermission? _locationPermission;
  bool _isLocationServiceEnabled = false;

  // Lists for dropdowns
  final List<String> _fuelTypes = [
    'Electric',
    'Petrol',
    'Diesel',
    'Hybrid',
    'CNG',
    'LPG',
  ];
  final List<String> _vehicleTypes = [
    'Car',
    'SUV',
    'Truck',
    'Motorcycle',
    'Van',
    'Bus',
  ];

  final List<Map<String, dynamic>> _membershipTiers = [
    {
      'id': 'tier1',
      'name': 'Cruiser',
      'description': 'Basic rewards & analytics',
      'price': 'Free',
      'popular': false,
      'cashback': '2%',
    },
    {
      'id': 'tier2',
      'name': 'Racer Pro',
      'description': '5% Cashback & Priority charging',
      'price': '\$9.99/mo',
      'popular': true,
      'cashback': '5%',
    },
    {
      'id': 'tier3',
      'name': 'Legend VIP',
      'description': 'Unlimited valet & Concierge',
      'price': '\$24.99/mo',
      'popular': false,
      'cashback': '10%',
    },
  ];

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkLocationStatus();
  }

  Future<void> _checkLocationStatus() async {
    // Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    setState(() {
      _isLocationServiceEnabled = serviceEnabled;
    });

    if (serviceEnabled) {
      // Check location permission
      await _checkLocationPermission();
    }
  }

  Future<void> _checkLocationPermission() async {
    _locationPermission = await Geolocator.checkPermission();

    if (_locationPermission == LocationPermission.deniedForever) {
      // Permission denied forever - show settings dialog
      // Optional: Do nothing or show a non-blocking hint
    } else if (_locationPermission == LocationPermission.denied) {
      // Permission denied - request permission
      _locationPermission = await Geolocator.requestPermission();

      if (_locationPermission == LocationPermission.whileInUse ||
          _locationPermission == LocationPermission.always) {
        // Permission granted, get location
        await _getCurrentLocation();
      }
    } else if (_locationPermission == LocationPermission.whileInUse ||
        _locationPermission == LocationPermission.always) {
      // Permission already granted, get location
      await _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    if (_locationPermission != LocationPermission.whileInUse &&
        _locationPermission != LocationPermission.always) {
      await _checkLocationPermission();
      if (_locationPermission != LocationPermission.whileInUse &&
          _locationPermission != LocationPermission.always) {
        return;
      }
    }

    if (!_isLocationServiceEnabled) {
      return;
    }

    try {
      setState(() => _isLoading = true);

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentPosition = position;
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      // Get address from coordinates
      await _getAddressFromLatLng(position.latitude, position.longitude);
    } catch (e) {
      if (e is TimeoutException) {
        _showError('Location request timed out. Please try again.');
      } else {
        _showError('Unable to get location: ${e.toString()}');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address =
            '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}'
                .trim();

        setState(() {
          _address = address.isNotEmpty ? address : 'Unknown Location';
          if (_locationController.text.isEmpty) {
            _locationController.text = _address;
          }
        });
      }
    } catch (e) {
      print('Error getting address: $e');
      // Set a default address if geocoding fails
      setState(() {
        _address =
            'Coordinates: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
        if (_locationController.text.isEmpty) {
          _locationController.text = 'Unknown Location';
        }
      });
    }
  }

  void _showLocationPermissionDialog({
    required String title,
    required String message,
    required bool isPermanent,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1b1f27),
        title: Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.grey[400]),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (isPermanent) {
                await openAppSettings();
              } else {
                await _checkLocationPermission();
              }
            },
            child: Text(
              isPermanent ? 'Open Settings' : 'Grant Permission',
              style: GoogleFonts.inter(
                color: const Color(0xFF256af4),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1b1f27),
        title: Text(
          'Location Services Disabled',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Please enable location services on your device to use this feature.',
          style: GoogleFonts.inter(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.grey[400]),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openLocationSettings();
            },
            child: Text(
              'Enable',
              style: GoogleFonts.inter(
                color: const Color(0xFF256af4),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _licenseController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _driverNameController.dispose();
    _driverEmailController.dispose();
    _driverPhoneController.dispose();
    _driverLicenseController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101622),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top App Bar
                  _buildTopAppBar(),

                  // Headline Section
                  _buildHeadlineSection(),

                  // Form Fields - Vehicle Details
                  _buildVehicleFormSection(),

                  // Form Fields - Driver Details
                  _buildDriverFormSection(),

                  // Location Section
                  _buildLocationSection(),

                  // Fuel Type Chips
                  _buildFuelTypeChips(),

                  // Vehicle Type Dropdown
                  _buildVehicleTypeDropdown(),

                  // Membership Toggle Section
                  _buildMembershipSection(),

                  // Bottom Action Buttons
                  _buildBottomActions(),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Loading Overlay
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF256af4),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: widget.onBackPressed ?? () => Navigator.pop(context),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          // Title
          Expanded(
            child: Text(
              'New User Registration',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.015,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Spacer for alignment
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildHeadlineSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Account & Register Vehicle',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your account and register your first vehicle',
            style: GoogleFonts.inter(
              color: const Color(0xFF94a3b8),
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleFormSection() {
    return Column(
      children: [
        // Section Title
        _buildSectionTitle('Vehicle Details'),

        // Car Brand Field
        _buildTextField(
          label: 'Car Brand',
          controller: _brandController,
          hintText: 'e.g. Tesla, Toyota, BMW',
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        ),

        // Model Field
        _buildTextField(
          label: 'Model',
          controller: _modelController,
          hintText: 'e.g. Model S, Camry, X5',
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        ),

        // Year Field
        _buildTextField(
          label: 'Manufacturing Year',
          controller: _yearController,
          hintText: 'e.g. 2023',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        ),

        // Color Field
        _buildTextField(
          label: 'Vehicle Color',
          controller: _colorController,
          hintText: 'e.g. Red, Blue, Black',
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        ),

        // License Plate Field
        _buildTextField(
          label: 'License Plate',
          controller: _licenseController,
          hintText: 'XYZ-1234',
          isUppercase: true,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        ),
      ],
    );
  }

  Widget _buildDriverFormSection() {
    return Column(
      children: [
        // Section Title
        _buildSectionTitle('Account Details'),

        // Driver Name Field
        _buildTextField(
          label: 'Full Name',
          controller: _driverNameController,
          hintText: 'John Doe',
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        ),

        // Driver Email Field
        _buildTextField(
          label: 'Email Address',
          controller: _driverEmailController,
          hintText: 'john.doe@email.com',
          keyboardType: TextInputType.emailAddress,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        ),

        // Password Field
        _buildPasswordField(
          label: 'Password',
          controller: _passwordController,
          hintText: 'Create a secure password',
          showPassword: _showPassword,
          onToggleVisibility: () {
            setState(() {
              _showPassword = !_showPassword;
            });
          },
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        ),

        // Confirm Password Field
        _buildPasswordField(
          label: 'Confirm Password',
          controller: _confirmPasswordController,
          hintText: 'Re-enter your password',
          showPassword: _showConfirmPassword,
          onToggleVisibility: () {
            setState(() {
              _showConfirmPassword = !_showConfirmPassword;
            });
          },
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        ),

        // Driver Phone Field
        _buildTextField(
          label: 'Phone Number',
          controller: _driverPhoneController,
          hintText: '+1 234 567 8900',
          keyboardType: TextInputType.phone,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        ),

        // Driver License Field
        _buildTextField(
          label: 'Driver License Number',
          controller: _driverLicenseController,
          hintText: 'DL-12345678',
          isUppercase: true,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    Color statusColor;
    IconData statusIcon;
    String statusTitle;
    String statusDescription;

    if (_isLocationServiceEnabled) {
      if (_locationPermission == LocationPermission.whileInUse ||
          _locationPermission == LocationPermission.always) {
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusTitle = 'Location Access Granted';
        statusDescription = _currentPosition != null
            ? 'Coordinates: ${_latitude?.toStringAsFixed(6)}, ${_longitude?.toStringAsFixed(6)}'
            : 'Tap GPS button to get location';
      } else if (_locationPermission == LocationPermission.deniedForever) {
        statusColor = Colors.red;
        statusIcon = Icons.error;
        statusTitle = 'Permission Permanently Denied';
        statusDescription = 'Location is optional';
      } else {
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        statusTitle = 'Permission Optional';
        statusDescription = 'Tap GPS button to enable';
      }
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.gps_off;
      statusTitle = 'Location Services Disabled';
      statusDescription = 'Enable location services on your device';
    }

    return Column(
      children: [
        // Section Title
        _buildSectionTitle('Location'),

        // Address Field with GPS Button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Row(
                  children: [
                    Text(
                      'Address',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFe2e8f0),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.gps_fixed,
                        color: _currentPosition != null
                            ? const Color(0xFF256af4)
                            : const Color(0xFF94a3b8),
                      ),
                      onPressed: _getCurrentLocation,
                      tooltip: 'Get current location',
                    ),
                  ],
                ),
              ),
              TextField(
                controller: _locationController,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your address',
                  hintStyle: GoogleFonts.inter(
                    color: const Color(0xFF94a3b8),
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1b1f27),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF3b4354),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF3b4354),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF256af4),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.my_location,
                      color: Color(0xFF256af4),
                    ),
                    onPressed: _getCurrentLocation,
                    tooltip: 'Get current location',
                  ),
                ),
              ),
            ],
          ),
        ),

        // Location Status
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: GestureDetector(
            onTap: () {
              if (_locationPermission == LocationPermission.deniedForever) {
                _showLocationPermissionDialog(
                  title: 'Location Permission Required',
                  message:
                      'Location permission is permanently denied. Please enable it from app settings.',
                  isPermanent: true,
                );
              } else if (!_isLocationServiceEnabled) {
                _showLocationServiceDialog();
              } else if (_locationPermission == LocationPermission.denied) {
                _checkLocationPermission();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusTitle,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          statusDescription,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF94a3b8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_locationPermission == LocationPermission.deniedForever ||
                      !_isLocationServiceEnabled)
                    const Icon(
                      Icons.settings,
                      color: Color(0xFF256af4),
                      size: 16,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Text(
        title,
        style: GoogleFonts.inter(
          color: const Color(0xFF256af4),
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    bool isUppercase = false,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: const Color(0xFFe2e8f0),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextField(
            controller: controller,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
            textCapitalization: isUppercase
                ? TextCapitalization.characters
                : TextCapitalization.none,
            keyboardType: keyboardType,
            obscureText: obscureText,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.inter(
                color: const Color(0xFF94a3b8),
                fontSize: 16,
              ),
              filled: true,
              fillColor: const Color(0xFF1b1f27),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF3b4354),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF3b4354),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF256af4),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required bool showPassword,
    required VoidCallback onToggleVisibility,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
  }) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: const Color(0xFFe2e8f0),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextField(
            controller: controller,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
            obscureText: !showPassword,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.inter(
                color: const Color(0xFF94a3b8),
                fontSize: 16,
              ),
              filled: true,
              fillColor: const Color(0xFF1b1f27),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF3b4354),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF3b4354),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF256af4),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  showPassword ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF94a3b8),
                ),
                onPressed: onToggleVisibility,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuelTypeChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Preferred Fuel Type',
              style: GoogleFonts.inter(
                color: const Color(0xFFe2e8f0),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 8,
              children: _fuelTypes.map((type) {
                final isSelected = type == _selectedFuelType;
                return ChoiceChip(
                  label: Text(
                    type,
                    style: GoogleFonts.inter(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFFe2e8f0),
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFuelType = type;
                    });
                  },
                  backgroundColor: const Color(0xFF1b1f27),
                  selectedColor: const Color(0xFF256af4),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF256af4)
                        : const Color(0xFF3b4354),
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Vehicle Type',
              style: GoogleFonts.inter(
                color: const Color(0xFFe2e8f0),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1b1f27),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF3b4354), width: 1),
            ),
            child: DropdownButton<String>(
              value: _selectedVehicleType,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedVehicleType = newValue;
                  });
                }
              },
              dropdownColor: const Color(0xFF1b1f27),
              style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF94a3b8)),
              isExpanded: true,
              items: _vehicleTypes.map<DropdownMenuItem<String>>((
                String value,
              ) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Membership Toggle Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1b1f27).withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF256af4).withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF256af4).withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon and Text
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF256af4).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Icon(
                    Icons.stars,
                    color: Color(0xFF256af4),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Join Car Union',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Unlock exclusive station rewards',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF94a3b8),
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),

                // Toggle Switch
                Switch(
                  value: _isMembershipEnabled,
                  onChanged: (value) {
                    setState(() {
                      _isMembershipEnabled = value;
                    });
                  },
                  activeThumbColor: const Color(0xFF256af4),
                  activeTrackColor: const Color(0xFF256af4).withOpacity(0.3),
                  inactiveTrackColor: const Color(0xFF3b4354),
                ),
              ],
            ),
          ),

          // Membership Tiers (only show if toggle is enabled)
          if (_isMembershipEnabled) ...[
            const SizedBox(height: 16),
            ..._membershipTiers.map((tier) {
              final isSelected = tier['name'] == _selectedTier;
              final isPopular = tier['popular'] == true;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTier = tier['name'] as String;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF256af4).withOpacity(0.1)
                          : const Color(0xFF1b1f27),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF256af4)
                            : const Color(0xFF3b4354),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TIER ${_membershipTiers.indexOf(tier) + 1}',
                                  style: GoogleFonts.inter(
                                    color: isSelected
                                        ? const Color(
                                            0xFF256af4,
                                          ).withOpacity(0.7)
                                        : const Color(0xFF94a3b8),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tier['name'] as String,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  tier['description'] as String,
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF94a3b8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  tier['price'] as String,
                                  style: GoogleFonts.inter(
                                    color: isSelected
                                        ? const Color(0xFF256af4)
                                        : Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${tier['cashback']} cashback',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF10b981),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Popular badge
                        if (isPopular)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF256af4),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(16),
                                  bottomLeft: Radius.circular(8),
                                ),
                              ),
                              child: Text(
                                'POPULAR',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      child: Column(
        children: [
          // Register Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _registerNewUserWithVehicle,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF256af4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                minimumSize: const Size(double.infinity, 56),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Create Account & Register Vehicle',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 12),

          // Skip Button
          TextButton(
            onPressed: _isLoading ? null : widget.onSkip,
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              'Skip for now',
              style: GoogleFonts.inter(
                color: const Color(0xFF94a3b8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _registerNewUserWithVehicle() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if email already exists
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _driverEmailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      final user = userCredential.user;
      if (user == null) throw Exception('User creation failed');

      // Update display name
      await user.updateDisplayName(_driverNameController.text.trim());

      // Prepare vehicle data
      final vehicleData = {
        'userId': user.uid,
        'brand': _brandController.text.trim(),
        'model': _modelController.text.trim(),
        'licensePlate': _licenseController.text.trim().toUpperCase(),
        'year': int.tryParse(_yearController.text) ?? 0,
        'color': _colorController.text.trim(),
        'fuelType': _selectedFuelType,
        'vehicleType': _selectedVehicleType,
        'membership': _isMembershipEnabled ? _selectedTier : 'None',
        'registrationDate': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'isActive': true,
        'isPrimaryVehicle': true, // Mark as primary vehicle
      };

      // Prepare driver/user data
      final userData = {
        'userId': user.uid,
        'email': _driverEmailController.text.trim(),
        'fullName': _driverNameController.text.trim(),
        'phone': _driverPhoneController.text.trim(),
        'driverLicense': _driverLicenseController.text.trim().toUpperCase(),
        'address': _locationController.text.trim(),
        'latitude': _latitude,
        'longitude': _longitude,
        'preferredFuelType': _selectedFuelType,
        'membershipStatus': _isMembershipEnabled ? _selectedTier : 'None',
        'role': 'driver',
        'registrationDate': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'isActive': true,
        'hasVehicleRegistered': true,
      };

      // Batch write for atomic operation
      final batch = _firestore.batch();

      // Add vehicle to vehicles collection
      final vehicleRef = _firestore.collection('vehicles').doc();
      batch.set(vehicleRef, vehicleData);

      // Add user to users collection
      final userRef = _firestore.collection('users').doc(user.uid);
      batch.set(userRef, {
        ...userData,
        'vehicleId': vehicleRef.id,
      });

      // Add driver to drivers collection
      final driverRef = _firestore.collection('drivers').doc(user.uid);
      batch.set(driverRef, {
        ...userData,
        'vehicleId': vehicleRef.id,
        'vehicleBrand': _brandController.text.trim(),
        'vehicleModel': _modelController.text.trim(),
        'vehicleLicensePlate': _licenseController.text.trim().toUpperCase(),
      });

      // Commit batch
      await batch.commit();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created and vehicle registered successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate on success
      widget.onCreateAccount();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showError('Email already registered. Please use a different email or login.');
      } else if (e.code == 'weak-password') {
        _showError('Password is too weak. Please use a stronger password.');
      } else {
        _showError('Registration failed: ${e.message}');
      }
    } catch (e) {
      _showError('Registration failed: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _validateForm() {
    // Vehicle validation
    if (_brandController.text.isEmpty) {
      _showError('Please enter car brand');
      return false;
    }
    if (_modelController.text.isEmpty) {
      _showError('Please enter car model');
      return false;
    }
    if (_licenseController.text.isEmpty) {
      _showError('Please enter license plate');
      return false;
    }
    if (_yearController.text.isEmpty) {
      _showError('Please enter manufacturing year');
      return false;
    }
    if (_colorController.text.isEmpty) {
      _showError('Please enter vehicle color');
      return false;
    }

    // Driver validation
    if (_driverNameController.text.isEmpty) {
      _showError('Please enter your full name');
      return false;
    }
    
    // Email validation
    if (_driverEmailController.text.isEmpty) {
      _showError('Please enter email address');
      return false;
    }
    
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(_driverEmailController.text.trim())) {
      _showError('Please enter a valid email address');
      return false;
    }

    // Password validation
    if (_passwordController.text.isEmpty) {
      _showError('Please enter a password');
      return false;
    }
    if (_passwordController.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return false;
    }
    
    // Confirm password validation
    if (_confirmPasswordController.text.isEmpty) {
      _showError('Please confirm your password');
      return false;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return false;
    }

    // Phone validation
    if (_driverPhoneController.text.isEmpty) {
      _showError('Please enter phone number');
      return false;
    }
    
    // Driver license validation
    if (_driverLicenseController.text.isEmpty) {
      _showError('Please enter driver license number');
      return false;
    }

    // Location validation
    if (_locationController.text.isEmpty) {
      _showError('Please enter your address');
      return false;
    }

    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
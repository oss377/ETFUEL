// // lib/screens/station_tab_navigator.dart
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'station_owner.dart';

// class StationTabNavigator extends StatefulWidget {
//   final String userName;
//   final VoidCallback onLogout;
  
//   const StationTabNavigator({
//     super.key,
//     required this.userName,
//     required this.onLogout,
//   });

//   @override
//   State<StationTabNavigator> createState() => _StationTabNavigatorState();
// }

// class _StationTabNavigatorState extends State<StationTabNavigator> {
//   int _selectedIndex = 0;
  
//   final List<StationTab> _tabs = [
//     StationTab(
//       icon: Icons.dashboard,
//       label: 'Dashboard',
//       page: const StationOwnerDashboard(),
//     ),
//     StationTab(
//       icon: Icons.local_gas_station,
//       label: 'Pumps',
//       page: Container(
//         color: const Color(0xFF080d0a),
//         child: Center(
//           child: Text(
//             'Pump Management',
//             style: GoogleFonts.inter(
//               color: Colors.white,
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     ),
//     StationTab(
//       icon: Icons.bar_chart,
//       label: 'Analytics',
//       page: Container(
//         color: const Color(0xFF080d0a),
//         child: Center(
//           child: Text(
//             'Analytics Dashboard',
//             style: GoogleFonts.inter(
//               color: Colors.white,
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     ),
//     StationTab(
//       icon: Icons.settings,
//       label: 'Settings',
//       page: Container(
//         color: const Color(0xFF080d0a),
//         child: Center(
//           child: Text(
//             'Station Settings',
//             style: GoogleFonts.inter(
//               color: Colors.white,
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF080d0a),
//       body: Stack(
//         children: [
//           // Main Content
//           IndexedStack(
//             index: _selectedIndex,
//             children: _tabs.map((tab) => tab.page).toList(),
//           ),
          
//           // Glass Navigation Bar at Top
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: GlassNavBarStation(
//               userName: widget.userName,
//               onLogout: widget.onLogout,
//               currentTab: _selectedIndex,
//               onTabChanged: (index) {
//                 setState(() {
//                   _selectedIndex = index;
//                 });
//               },
//             ),
//           ),
          
//           // Bottom Tab Bar
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: _buildBottomTabBar(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBottomTabBar() {
//     return Container(
//       height: 80,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: const Color(0xFF080d0a).withOpacity(0.95),
//         border: Border(
//           top: BorderSide(color: const Color(0xFF0df259).withOpacity(0.2)),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.5),
//             blurRadius: 20,
//             offset: const Offset(0, -4),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: _tabs.asMap().entries.map((entry) {
//           final index = entry.key;
//           final tab = entry.value;
//           final isActive = index == _selectedIndex;

//           return GestureDetector(
//             onTap: () {
//               setState(() {
//                 _selectedIndex = index;
//               });
//             },
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 300),
//               curve: Curves.easeOutBack,
//               padding: EdgeInsets.symmetric(
//                 horizontal: isActive ? 20 : 16,
//                 vertical: 10,
//               ),
//               decoration: isActive
//                   ? BoxDecoration(
//                       color: const Color(0xFF0df259).withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(30),
//                       border: Border.all(
//                         color: const Color(0xFF0df259).withOpacity(0.4),
//                       ),
//                     )
//                   : null,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(
//                     tab.icon,
//                     color: isActive
//                         ? const Color(0xFF0df259)
//                         : Colors.grey[500],
//                     size: 24,
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     tab.label,
//                     style: GoogleFonts.inter(
//                       color: isActive
//                           ? const Color(0xFF0df259)
//                           : Colors.grey[500],
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }

// class StationTab {
//   final IconData icon;
//   final String label;
//   final Widget page;

//   StationTab({
//     required this.icon,
//     required this.label,
//     required this.page,
//   });
// }
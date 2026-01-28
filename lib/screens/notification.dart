import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationCenter extends StatefulWidget {
  const NotificationCenter({super.key});

  @override
  State<NotificationCenter> createState() => _NotificationCenterState();
}

class _NotificationCenterState extends State<NotificationCenter> {
  final List<NotificationItem> notifications = [
    NotificationItem(
      id: 1,
      title: 'Low Fuel Alert',
      timeAgo: '2m ago',
      message:
          'Your tank is at 10%. Nearby Shell station has \$0.15 off for Union members.',
      icon: Icons.local_gas_station,
      iconColor: Colors.amber[400]!,
      backgroundColor: Colors.amber.withOpacity(0.1),
      glowColor: Colors.amber,
      category: 'Fuel',
      isUnread: true,
    ),
    NotificationItem(
      id: 2,
      title: 'Union Membership',
      timeAgo: '1h ago',
      message:
          'Your roadside assistance plan has been successfully renewed until 2025.',
      icon: Icons.shield,
      iconColor: Colors.blue[400]!,
      backgroundColor: Colors.blue.withOpacity(0.1),
      glowColor: Colors.blue,
      category: 'Union',
      isUnread: true,
    ),
    NotificationItem(
      id: 3,
      title: 'Payment Successful',
      timeAgo: '3h ago',
      message: 'Transaction of \$42.50 at Downtown Mobile Station confirmed.',
      icon: Icons.payments,
      iconColor: Colors.green[400]!,
      backgroundColor: Colors.green.withOpacity(0.1),
      glowColor: Colors.green,
      category: 'Payment',
      isUnread: true,
    ),
    NotificationItem(
      id: 4,
      title: 'Service Reminder',
      timeAgo: 'Yesterday',
      message:
          'It\'s time for your scheduled oil change. Book a Union-approved garage nearby.',
      icon: Icons.build_circle,
      iconColor: Colors.grey[400]!,
      backgroundColor: Colors.grey.withOpacity(0.1),
      glowColor: Colors.grey,
      category: 'Service',
      isUnread: false,
    ),
    NotificationItem(
      id: 5,
      title: 'Weekend Bonus',
      timeAgo: 'Yesterday',
      message:
          'Earn 2x reward points on all premium fuel purchases this weekend.',
      icon: Icons.celebration,
      iconColor: Colors.purple[400]!,
      backgroundColor: Colors.purple.withOpacity(0.1),
      glowColor: Colors.purple,
      category: 'Promo',
      isUnread: false,
    ),
    NotificationItem(
      id: 6,
      title: 'Rate Your Visit',
      timeAgo: '2d ago',
      message: 'How was your experience at Shell Station? Tap to rate.',
      icon: Icons.star,
      iconColor: Colors.yellow[400]!,
      backgroundColor: Colors.yellow.withOpacity(0.1),
      glowColor: Colors.yellow,
      category: 'Feedback',
      isUnread: false,
    ),
    NotificationItem(
      id: 7,
      title: 'Policy Update',
      timeAgo: '3d ago',
      message: 'We have updated our privacy policy and terms of service.',
      icon: Icons.policy,
      iconColor: Colors.blueGrey[400]!,
      backgroundColor: Colors.blueGrey.withOpacity(0.1),
      glowColor: Colors.blueGrey,
      category: 'System',
      isUnread: false,
    ),
    NotificationItem(
      id: 8,
      title: 'Refer a Friend',
      timeAgo: '1w ago',
      message: 'Invite friends to join the Union and earn \$10 credit each.',
      icon: Icons.person_add,
      iconColor: Colors.pink[400]!,
      backgroundColor: Colors.pink.withOpacity(0.1),
      glowColor: Colors.pink,
      category: 'Promo',
      isUnread: false,
    ),
  ];

  int _activeTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0e),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [Color(0xFF0a0a0e), Color(0xFF0a0a0e)],
            stops: [0, 1],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top App Bar
              _buildTopAppBar(),

              // Tabs
              _buildTabs(),

              // Notification List
              Expanded(child: _buildNotificationList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0a0a0e).withAlpha(204),
        border: const Border(
          bottom: BorderSide(color: Color.fromRGBO(255, 255, 255, 0.05)),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 255, 255, 0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Activity',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                for (var notification in notifications) {
                  notification.isUnread = false;
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF256af4).withAlpha(26),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF256af4).withAlpha(51),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF256af4).withAlpha(51),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Text(
                'Mark Read',
                style: GoogleFonts.inter(
                  color: const Color(0xFF256af4),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 255, 255, 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.1)),
        ),
        child: Row(
          children: [
            _buildTabButton('ALL', 0),
            _buildTabButton('FUEL', 1),
            _buildTabButton('UNION', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isActive = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeTab = index;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF256af4) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF256af4).withAlpha(128),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: isActive ? Colors.white : const Color(0xFF64748b),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationList() {
    List<NotificationItem> filteredNotifications;

    if (_activeTab == 0) {
      filteredNotifications = notifications;
    } else if (_activeTab == 1) {
      filteredNotifications = notifications
          .where((n) => n.category == 'Fuel')
          .toList();
    } else {
      filteredNotifications = notifications
          .where((n) => n.category == 'Union')
          .toList();
    }

    final todayNotifications = filteredNotifications
        .where((notification) => !notification.timeAgo.contains('Yesterday'))
        .toList();

    final yesterdayNotifications = filteredNotifications
        .where((notification) => notification.timeAgo.contains('Yesterday'))
        .toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // Today's notifications
        if (todayNotifications.isNotEmpty) ...[
          ...todayNotifications.map(_buildNotificationItem),
        ],

        // Yesterday section header
        if (yesterdayNotifications.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
            child: Text(
              'YESTERDAY',
              style: GoogleFonts.inter(
                color: const Color(0xFF64748b),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
          ),
          ...yesterdayNotifications.map(_buildNotificationItem),
        ],

        // Empty state
        if (filteredNotifications.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Column(
                children: [
                  Icon(
                    Icons.notifications_off,
                    color: Colors.grey[600],
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: GoogleFonts.inter(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.withAlpha(51),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withAlpha(77)),
        ),
        child: const Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.delete, color: Colors.red, size: 24),
          ),
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          notifications.removeWhere((item) => item.id == notification.id);
        });
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            notification.isUnread = false;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border(
              top: const BorderSide(color: Color.fromRGBO(255, 255, 255, 0.1)),
              right: const BorderSide(
                color: Color.fromRGBO(255, 255, 255, 0.1),
              ),
              bottom: const BorderSide(
                color: Color.fromRGBO(255, 255, 255, 0.1),
              ),
              left: BorderSide(
                color: notification.isUnread
                    ? const Color(0xFF256af4)
                    : Colors.transparent,
                width: 4,
              ),
            ),
          ),
          child: Opacity(
            opacity: notification.isUnread ? 1.0 : 0.7,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: notification.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: notification.isUnread
                          ? [
                              BoxShadow(
                                color: notification.glowColor.withAlpha(77),
                                blurRadius: 8,
                                spreadRadius: 0,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      notification.icon,
                      color: notification.iconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              notification.title,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              notification.timeAgo.toUpperCase(),
                              style: GoogleFonts.inter(
                                color: const Color(0xFF64748b),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF94a3b8),
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NotificationItem {
  final int id;
  final String title;
  final String timeAgo;
  final String message;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color glowColor;
  final String category;
  bool isUnread;

  NotificationItem({
    required this.id,
    required this.title,
    required this.timeAgo,
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.glowColor,
    required this.category,
    required this.isUnread,
  });
}

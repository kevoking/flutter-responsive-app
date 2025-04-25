// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

// BLoC related imports
import 'bloc/navigation_bloc.dart';
import 'features/authentication/bloc/auth_bloc.dart';
import 'features/authentication/repository/auth_repository.dart';
import 'features/authentication/widgets/auth_wrapper.dart';
// UI related imports
import 'features/authentication/widgets/user_profile_widget.dart';
import 'features/home/screens/home_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/notifications/screens/notifications_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => NavigationBloc(),
        ),
        BlocProvider(
          create: (context) => AuthBloc(
            authRepository: AuthRepository(
              baseUrl: 'https://api.yourapp.com', // Replace with your API URL
            ),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Responsive Navigation',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class ResponsiveNavigation extends StatelessWidget {
  const ResponsiveNavigation({super.key});

  bool isLargeScreen(BuildContext context) {
    // Desktop or Web with large width
    return MediaQuery.of(context).size.width > 900 || 
           (kIsWeb && MediaQuery.of(context).size.width > 600) ||
           (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(state.title),
            // Show menu button on small screens when sidebar is collapsed
            leading: isLargeScreen(context) ? 
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => context.read<NavigationBloc>().add(ToggleSidebarEvent()),
              ) : null,
          ),
          body: Row(
            children: [
              // Collapsible sidebar for large screens
              if (isLargeScreen(context))
                BlocBuilder<NavigationBloc, NavigationState>(
                  builder: (context, state) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: state.isSidebarExpanded ? 240.0 : 70.0,
                      child: Sidebar(
                        isExpanded: state.isSidebarExpanded,
                        currentIndex: state.currentIndex,
                      ),
                    );
                  },
                ),
              // Main content
              Expanded(
                child: _buildBody(state.currentIndex),
              ),
            ],
          ),
          // Bottom navigation for mobile screens
          bottomNavigationBar: isLargeScreen(context)
              ? null
              : CustomBottomNavBar(
                  currentIndex: state.currentIndex,
                ),
        );
      },
    );
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const ProfileScreen();
      case 2:
        return const NotificationsScreen();
      case 3:
        return const SettingsScreen();
      default:
        return const HomeScreen();
    }
  }
}

// Custom Sidebar for desktop
// Update the Sidebar class to include user profile
class Sidebar extends StatelessWidget {
  final bool isExpanded;
  final int currentIndex;

  const Sidebar({
    Key? key,
    required this.isExpanded,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // User profile section
          if (isExpanded)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: UserProfileWidget(),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: UserProfileWidget(),
            ),
          const Divider(),
          // Navigation items remain the same...
          _buildNavItem(context, 'Home', Icons.home, 0),
          _buildNavItem(context, 'Profile', Icons.person, 1),
          _buildNavItem(context, 'Notifications', Icons.notifications, 2),
          _buildNavItem(context, 'Settings', Icons.settings, 3),
          const Spacer(),
          // Logout button
          if (!isExpanded)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                // Handle logout action
                context.read<AuthBloc>().add(LogoutEvent());
              },
            ),
          // Expand/collapse button remains the same...
          if (isExpanded)
            ListTile(
              leading: const Icon(Icons.chevron_left),
              title: const Text('Collapse'),
              onTap: () {
                context.read<NavigationBloc>().add(ToggleSidebarEvent());
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                context.read<NavigationBloc>().add(ToggleSidebarEvent());
              },
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String title, IconData icon, int index) {
    // Same implementation as before...
    final isSelected = currentIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
      ),
      title: isExpanded
          ? Text(
              title,
              style: TextStyle(
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            )
          : null,
      selected: isSelected,
      onTap: () {
        context.read<NavigationBloc>().add(NavigateToEvent(index, title));
      },
    );
  }

}

// Custom BottomNavigationBar for mobile
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        String title;
        switch (index) {
          case 0:
            title = 'Home';
            break;
          case 1:
            title = 'Profile';
            break;
          case 2:
            title = 'Notifications';
            break;
          case 3:
            title = 'Settings';
            break;
          default:
            title = 'Home';
        }
        context.read<NavigationBloc>().add(NavigateToEvent(index, title));
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
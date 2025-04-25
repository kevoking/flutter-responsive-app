// auth/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../screens/login_screen.dart';
import '../../../main.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger check auth status when the app starts
    context.read<AuthBloc>().add(CheckAuthStatusEvent());
    
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          // Show splash screen while checking auth
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is Authenticated) {
          // User is logged in, show main app
          return const ResponsiveNavigation();
        } else {
          // User is not authenticated, show login
          return const LoginScreen();
        }
      },
    );
  }
}
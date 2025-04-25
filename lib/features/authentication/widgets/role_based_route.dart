// auth/role_based_route.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../models/user_model.dart';

class RoleBasedRoute extends StatelessWidget {
  final Widget child;
  final List<String> requiredRoles;
  final Widget fallback;

  const RoleBasedRoute({
    super.key,
    required this.child,
    required this.requiredRoles,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          final User user = state.user;
          final bool hasAccess = requiredRoles.isEmpty || 
              requiredRoles.any((role) => user.hasRole(role));
          
          if (hasAccess) {
            return child;
          }
        }
        
        return fallback;
      },
    );
  }
}
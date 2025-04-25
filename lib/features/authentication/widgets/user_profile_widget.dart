// User Profile Widget for the app
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/navigation_bloc.dart';
import '../bloc/auth_bloc.dart';

class UserProfileWidget extends StatelessWidget {
  const UserProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // check if sidebar is open or closed
    final isSidebarExpanded = context.watch<NavigationBloc>().state.isSidebarExpanded;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          final user = state.user;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: user.photoUrl != null 
                      ? NetworkImage(user.photoUrl!) 
                      : null,
                  child: user.photoUrl == null 
                      ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?') 
                      : null,
                ),
                if (MediaQuery.sizeOf(context).width > 350) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user.email,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
                if (isSidebarExpanded)
                  IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: 'Logout',
                    onPressed: () {
                      // Show confirmation dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('CANCEL'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                context.read<AuthBloc>().add(LogoutEvent());
                              },
                              child: const Text('LOGOUT'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
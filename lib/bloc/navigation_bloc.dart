// navigation_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class NavigationEvent {}

class NavigateToEvent extends NavigationEvent {
  final int index;
  final String title;

  NavigateToEvent(this.index, this.title);
}

class ToggleSidebarEvent extends NavigationEvent {}

// State
class NavigationState {
  final int currentIndex;
  final bool isSidebarExpanded;
  final String title;

  NavigationState({
    required this.currentIndex,
    required this.isSidebarExpanded,
    required this.title,
  });

  NavigationState copyWith({
    int? currentIndex,
    bool? isSidebarExpanded,
    String? title,
  }) {
    return NavigationState(
      currentIndex: currentIndex ?? this.currentIndex,
      isSidebarExpanded: isSidebarExpanded ?? this.isSidebarExpanded,
      title: title ?? this.title,
    );
  }
}

// BLoC
class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc()
      : super(NavigationState(
          currentIndex: 0,
          isSidebarExpanded: true,
          title: 'Home',
        )) {
    on<NavigateToEvent>(_onNavigateTo);
    on<ToggleSidebarEvent>(_onToggleSidebar);
  }

  void _onNavigateTo(NavigateToEvent event, Emitter<NavigationState> emit) {
    emit(state.copyWith(
      currentIndex: event.index,
      title: event.title,
    ));
  }

  void _onToggleSidebar(ToggleSidebarEvent event, Emitter<NavigationState> emit) {
    emit(state.copyWith(
      isSidebarExpanded: !state.isSidebarExpanded,
    ));
  }
}
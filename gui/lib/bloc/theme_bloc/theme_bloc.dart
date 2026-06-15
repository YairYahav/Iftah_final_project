// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'theme_event.dart';
part 'theme_state.dart';

/// This bloc is responsible of the theme management of your app,
/// and also is in charge of the theme change,
/// you can find the themes in main_page.dart
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState.inital()) {
    on<ToggleThemeEvent>(_toggleTheme);
  }

  void _toggleTheme(ToggleThemeEvent event, Emitter<ThemeState> emit) {
    emit(state.copyWith(
        appTheme:
            state.appTheme == AppTheme.dark ? AppTheme.light : AppTheme.dark));
  }
}

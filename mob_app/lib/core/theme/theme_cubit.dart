import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class ThemeState extends Equatable {
  const ThemeState({
    required this.accentColor,
    required this.isDark,
  });

  /// The currently active accent/primary color.
  final Color accentColor;

  /// Dark mode toggle — always true for now, wired up for future light mode.
  final bool isDark;

  ThemeState copyWith({Color? accentColor, bool? isDark}) {
    return ThemeState(
      accentColor: accentColor ?? this.accentColor,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  List<Object?> get props => [accentColor.toARGB32(), isDark];
}

// ---------------------------------------------------------------------------
// Cubit
// ---------------------------------------------------------------------------

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit(this._prefs)
      : super(ThemeState(
          accentColor: _loadAccent(_prefs),
          isDark: _prefs.getBool(_kIsDarkKey) ?? true,
        ));

  final SharedPreferences _prefs;

  static const String _kAccentKey  = 'mob_accent_color';
  static const String _kIsDarkKey  = 'mob_is_dark';

  // ---- Persistence helpers -------------------------------------------------

  static Color _loadAccent(SharedPreferences prefs) {
    final saved = prefs.getInt(_kAccentKey);
    if (saved != null) return Color(saved);
    return AppColors.primary; // Electric Blue default
  }

  static int _colorToInt(Color color) => color.toARGB32();

  // ---- Public API ----------------------------------------------------------

  /// Change the accent color and persist it.
  Future<void> setAccentColor(Color color) async {
    await _prefs.setInt(_kAccentKey, _colorToInt(color));
    emit(state.copyWith(accentColor: color));
  }

  /// Reset accent to the Mob brand default.
  Future<void> resetAccent() => setAccentColor(AppColors.primary);

  /// Toggle dark / light mode (light theme wired for future use).
  Future<void> setDarkMode({required bool dark}) async {
    await _prefs.setBool(_kIsDarkKey, dark);
    emit(state.copyWith(isDark: dark));
  }
}

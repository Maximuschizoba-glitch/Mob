import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../core/constants/app_spacing.dart';

/// Mob theme factory.
///
/// Usage:
/// ```dart
/// // Static dark theme (no accent customisation)
/// MobTheme.darkTheme
///
/// // Dynamic — driven by ThemeCubit accent color
/// MobTheme.fromAccent(accentColor)
/// ```
class MobTheme {
  MobTheme._();

  // ---------------------------------------------------------------------------
  // Public entry-points
  // ---------------------------------------------------------------------------

  /// Default dark theme using the locked brand primary (#3D6FFF).
  static ThemeData get darkTheme => fromAccent(AppColors.primary);

  /// Build a dark theme with a custom [accent] color.
  /// All interactive elements (buttons, focus rings, chips, tabs, etc.)
  /// adopt the provided accent — everything else stays on the brand palette.
  static ThemeData fromAccent(Color accent) {
    // Derived tones from the accent
    final Color accentDim   = accent.withValues(alpha: 0.15);
    final Color accentFaint = accent.withValues(alpha: 0.08);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // ------------------------------------------------------------------
      // Base surface colors (brand palette — never change with accent)
      // ------------------------------------------------------------------
      scaffoldBackgroundColor: AppColors.background,
      cardColor:               AppColors.card,
      canvasColor:             AppColors.background,
      primaryColor:            accent,

      colorScheme: ColorScheme.dark(
        brightness:              Brightness.dark,
        primary:                 accent,
        onPrimary:               AppColors.background,
        secondary:               AppColors.purple,
        onSecondary:             AppColors.textPrimary,
        tertiary:                AppColors.cyan,
        error:                   AppColors.error,
        onError:                 AppColors.textPrimary,
        surface:                 AppColors.card,
        onSurface:               AppColors.textPrimary,
        surfaceContainerHighest: AppColors.elevated,
        outline:                 AppColors.border,
        outlineVariant:          AppColors.borderLight,
      ),

      // ------------------------------------------------------------------
      // AppBar
      // ------------------------------------------------------------------
      appBarTheme: const AppBarTheme(
        backgroundColor:       Colors.transparent,
        elevation:             0,
        scrolledUnderElevation: 0,
        centerTitle:           false,
        titleTextStyle:        AppTypography.h3,
        iconTheme:             IconThemeData(color: AppColors.textPrimary, size: 24),
        actionsIconTheme:      IconThemeData(color: AppColors.textPrimary, size: 24),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor:             Colors.transparent,
          statusBarIconBrightness:    Brightness.light,
          statusBarBrightness:        Brightness.dark,
        ),
      ),

      // ------------------------------------------------------------------
      // Bottom nav
      // ------------------------------------------------------------------
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor:        AppColors.background,
        selectedItemColor:      accent,
        unselectedItemColor:    AppColors.textTertiary,
        type:                   BottomNavigationBarType.fixed,
        elevation:              0,
        showUnselectedLabels:   true,
        selectedLabelStyle: const TextStyle(
          fontFamily:  'Inter',
          fontSize:    11,
          fontWeight:  FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily:  'Inter',
          fontSize:    11,
          fontWeight:  FontWeight.w400,
        ),
      ),

      // ------------------------------------------------------------------
      // Text
      // ------------------------------------------------------------------
      textTheme: const TextTheme(
        displayLarge:  AppTypography.display,
        headlineLarge: AppTypography.h1,
        headlineMedium: AppTypography.h2,
        headlineSmall: AppTypography.h3,
        titleLarge:    AppTypography.h4,
        titleMedium:   AppTypography.bodyLarge,
        bodyLarge:     AppTypography.bodyLarge,
        bodyMedium:    AppTypography.body,
        bodySmall:     AppTypography.bodySmall,
        labelLarge:    AppTypography.button,
        labelMedium:   AppTypography.buttonSmall,
        labelSmall:    AppTypography.caption,
      ),

      // ------------------------------------------------------------------
      // Input fields
      // ------------------------------------------------------------------
      inputDecorationTheme: InputDecorationTheme(
        filled:      true,
        fillColor:   AppColors.elevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical:   AppSpacing.md,
        ),
        hintStyle:        AppTypography.body.copyWith(color: AppColors.textTertiary),
        labelStyle:       AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
        errorStyle:       AppTypography.caption.copyWith(color: AppColors.error),
        prefixIconColor:  AppColors.textSecondary,
        suffixIconColor:  AppColors.textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide:   const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide:   const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide:   BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide:   const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide:   const BorderSide(color: AppColors.error, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide:   const BorderSide(color: AppColors.border, width: 1),
        ),
        constraints: const BoxConstraints(minHeight: AppSpacing.inputHeight),
      ),

      // ------------------------------------------------------------------
      // Buttons
      // ------------------------------------------------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:         accent,
          foregroundColor:         AppColors.background,
          disabledBackgroundColor: AppColors.surface,
          disabledForegroundColor: AppColors.textDisabled,
          elevation:    0,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          textStyle:   AppTypography.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical:   AppSpacing.md,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor:         accent,
          disabledForegroundColor: AppColors.textDisabled,
          elevation:   0,
          minimumSize: const Size(double.infinity, 44),
          textStyle:   AppTypography.buttonSmall,
          side:        BorderSide(color: accent, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical:   AppSpacing.md,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle:       AppTypography.buttonSmall,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical:   AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ),

      iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(AppColors.textPrimary),
        ),
      ),

      // ------------------------------------------------------------------
      // Bottom sheet
      // ------------------------------------------------------------------
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor:      AppColors.card,
        surfaceTintColor:     Colors.transparent,
        modalBackgroundColor: AppColors.card,
        modalBarrierColor:    Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.bottomSheetRadius,
        ),
        elevation:       0,
        showDragHandle:  true,
        dragHandleColor: AppColors.surface,
        dragHandleSize:  Size(40, 4),
      ),

      // ------------------------------------------------------------------
      // Card
      // ------------------------------------------------------------------
      cardTheme: CardThemeData(
        color:            AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation:        0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: const BorderSide(color: AppColors.border, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),

      // ------------------------------------------------------------------
      // Chip
      // ------------------------------------------------------------------
      chipTheme: ChipThemeData(
        backgroundColor:        AppColors.elevated,
        disabledColor:          AppColors.surface,
        selectedColor:          accentDim,
        secondarySelectedColor: AppColors.purple,
        labelStyle:       AppTypography.buttonSmall,
        secondaryLabelStyle: AppTypography.buttonSmall,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        side:          const BorderSide(color: AppColors.border, width: 1),
        showCheckmark: false,
      ),

      // ------------------------------------------------------------------
      // Divider
      // ------------------------------------------------------------------
      dividerTheme: const DividerThemeData(
        color:     AppColors.border,
        thickness: 1,
        space:     1,
      ),

      // ------------------------------------------------------------------
      // Dialog
      // ------------------------------------------------------------------
      dialogTheme: DialogThemeData(
        backgroundColor:  AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation:        0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        titleTextStyle:   AppTypography.h3,
        contentTextStyle: AppTypography.body,
      ),

      // ------------------------------------------------------------------
      // Snack bar
      // ------------------------------------------------------------------
      snackBarTheme: SnackBarThemeData(
        backgroundColor:   AppColors.elevated,
        contentTextStyle:  AppTypography.body,
        actionTextColor:   accent,
        behavior:          SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        elevation: 4,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical:   AppSpacing.md,
        ),
      ),

      // ------------------------------------------------------------------
      // Tab bar
      // ------------------------------------------------------------------
      tabBarTheme: TabBarThemeData(
        indicatorColor:        accent,
        labelColor:            AppColors.textPrimary,
        unselectedLabelColor:  AppColors.textTertiary,
        labelStyle:            AppTypography.buttonSmall,
        unselectedLabelStyle:  AppTypography.buttonSmall,
        indicatorSize:         TabBarIndicatorSize.label,
        dividerColor:          Colors.transparent,
      ),

      // ------------------------------------------------------------------
      // Progress indicator
      // ------------------------------------------------------------------
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color:             accent,
        linearTrackColor:  AppColors.surface,
        circularTrackColor: AppColors.surface,
      ),

      // ------------------------------------------------------------------
      // Switch
      // ------------------------------------------------------------------
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accent;
          return AppColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accentDim;
          return AppColors.surface;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // ------------------------------------------------------------------
      // Scrollbar
      // ------------------------------------------------------------------
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
          AppColors.textTertiary.withValues(alpha: 0.5),
        ),
        radius:    const Radius.circular(4),
        thickness: WidgetStateProperty.all(4),
      ),

      // ------------------------------------------------------------------
      // Tooltip
      // ------------------------------------------------------------------
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color:        AppColors.elevated,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        textStyle: AppTypography.caption.copyWith(color: AppColors.textPrimary),
      ),

      // ------------------------------------------------------------------
      // FAB
      // ------------------------------------------------------------------
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: AppColors.background,
        elevation:       4,
        shape:           const CircleBorder(),
      ),

      // ------------------------------------------------------------------
      // Ripple / splash
      // ------------------------------------------------------------------
      splashColor:    accentFaint,
      highlightColor: accentFaint,

      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}

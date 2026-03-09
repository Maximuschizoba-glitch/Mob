import 'package:flutter/material.dart';


class AppSpacing {
  AppSpacing._();


  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;
  static const double huge = 48.0;


  static const EdgeInsets screenPadding =
      EdgeInsets.symmetric(horizontal: 20.0);

  static const EdgeInsets screenPaddingAll =
      EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0);

  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);

  static const EdgeInsets cardPaddingCompact =
      EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0);

  static const EdgeInsets listItemPadding =
      EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);

  static const EdgeInsets chipPadding =
      EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0);

  static const EdgeInsets bottomSheetPadding =
      EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 32.0);


  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;
  static const double radiusFull = 100.0;


  static final BorderRadius cardRadius =
      BorderRadius.circular(radiusLg);


  static final BorderRadius buttonRadius =
      BorderRadius.circular(radiusMd);


  static final BorderRadius inputRadius =
      BorderRadius.circular(radiusMd);


  static const BorderRadius bottomSheetRadius = BorderRadius.only(
    topLeft: Radius.circular(radiusXxl),
    topRight: Radius.circular(radiusXxl),
  );


  static final BorderRadius chipRadius =
      BorderRadius.circular(radiusFull);


  static const double buttonHeight = 48.0;
  static const double buttonHeightLg = 52.0;
  static const double inputHeight = 48.0;
  static const double bottomNavHeight = 80.0;
  static const double chipHeight = 32.0;
  static const double postButtonSize = 56.0;


  static const double avatarSm = 36.0;
  static const double avatarMd = 48.0;
  static const double avatarLg = 64.0;
  static const double avatarXl = 96.0;


  static const double mapPinWidth = 24.0;
  static const double mapPinHeight = 32.0;


  static const double pinPreviewHeight = 220.0;


  static const SizedBox verticalXs = SizedBox(height: xs);
  static const SizedBox verticalSm = SizedBox(height: sm);
  static const SizedBox verticalMd = SizedBox(height: md);
  static const SizedBox verticalBase = SizedBox(height: base);
  static const SizedBox verticalLg = SizedBox(height: lg);
  static const SizedBox verticalXl = SizedBox(height: xl);
  static const SizedBox verticalXxl = SizedBox(height: xxl);
  static const SizedBox verticalXxxl = SizedBox(height: xxxl);


  static const SizedBox horizontalXs = SizedBox(width: xs);
  static const SizedBox horizontalSm = SizedBox(width: sm);
  static const SizedBox horizontalMd = SizedBox(width: md);
  static const SizedBox horizontalBase = SizedBox(width: base);
  static const SizedBox horizontalLg = SizedBox(width: lg);
  static const SizedBox horizontalXl = SizedBox(width: xl);
}

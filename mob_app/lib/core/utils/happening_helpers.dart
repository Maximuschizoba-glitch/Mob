import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../../features/feed/domain/entities/happening.dart';
import '../../shared/models/enums.dart';
import '../constants/app_colors.dart';


enum HappeningDisplayStatus { live, upcoming, ended, hidden, expired }


HappeningDisplayStatus getDisplayStatus(Happening happening) {

  final ds = happening.displayStatus;
  if (ds != null) {
    debugPrint(
      '[Mob/DisplayStatus] "${happening.title}" '
      'using backend display_status=$ds',
    );
    switch (ds) {
      case 'live':
        return HappeningDisplayStatus.live;
      case 'upcoming':
        return HappeningDisplayStatus.upcoming;
      case 'expired':
        return HappeningDisplayStatus.expired;
      case 'hidden':
        return HappeningDisplayStatus.hidden;
      case 'ended':
        return HappeningDisplayStatus.ended;
    }
  }


  if (happening.status == HappeningStatus.hidden ||
      happening.status == HappeningStatus.reported) {
    return HappeningDisplayStatus.hidden;
  }


  if (happening.status == HappeningStatus.completed) {
    return HappeningDisplayStatus.ended;
  }

  if (happening.status == HappeningStatus.expired || happening.isExpired) {
    return HappeningDisplayStatus.expired;
  }

  final now = DateTime.now();
  final startsAt = happening.startsAt;
  final isUpcoming = startsAt != null && startsAt.isAfter(now);

  debugPrint(
    '[Mob/DisplayStatus] "${happening.title}" '
    'FALLBACK startsAt=$startsAt (isUtc=${startsAt?.isUtc}) '
    'now=$now '
    'isUpcoming=$isUpcoming '
    'status=${happening.status}',
  );

  if (isUpcoming) {
    return HappeningDisplayStatus.upcoming;
  }

  if (happening.status == HappeningStatus.active) {
    return HappeningDisplayStatus.live;
  }

  return HappeningDisplayStatus.ended;
}


({String label, Color color, bool pulse}) getBadgeConfig(
  HappeningDisplayStatus status,
) {
  switch (status) {
    case HappeningDisplayStatus.live:
      return (label: 'LIVE', color: AppColors.magenta, pulse: true);
    case HappeningDisplayStatus.upcoming:
      return (label: 'UPCOMING', color: AppColors.cyan, pulse: false);
    case HappeningDisplayStatus.ended:
      return (label: 'ENDED', color: AppColors.textTertiary, pulse: false);
    case HappeningDisplayStatus.hidden:
      return (label: 'HIDDEN', color: AppColors.error, pulse: false);
    case HappeningDisplayStatus.expired:
      return (label: 'EXPIRED', color: AppColors.textTertiary, pulse: false);
  }
}

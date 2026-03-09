import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';


enum HappeningCategory {
  partyNightlife('party_nightlife'),
  foodDrinks('food_drinks'),
  hangoutsSocial('hangouts_social'),
  musicPerformance('music_performance'),
  gamesActivities('games_activities'),
  artCulture('art_culture'),
  studyWork('study_work'),
  popupsStreet('popups_street');

  const HappeningCategory(this.value);


  final String value;


  static HappeningCategory? fromString(String? value) {
    if (value == null) return null;
    for (final category in HappeningCategory.values) {
      if (category.value == value) return category;
    }
    return null;
  }


  String get displayName {
    switch (this) {
      case HappeningCategory.partyNightlife:
        return 'Party / Nightlife';
      case HappeningCategory.foodDrinks:
        return 'Food & Drinks';
      case HappeningCategory.hangoutsSocial:
        return 'Hangouts / Social';
      case HappeningCategory.musicPerformance:
        return 'Music & Performance';
      case HappeningCategory.gamesActivities:
        return 'Games & Activities';
      case HappeningCategory.artCulture:
        return 'Art & Culture';
      case HappeningCategory.studyWork:
        return 'Study / Work Spots';
      case HappeningCategory.popupsStreet:
        return 'Pop-Ups & Street';
    }
  }


  String get emoji {
    switch (this) {
      case HappeningCategory.partyNightlife:
        return '🎉';
      case HappeningCategory.foodDrinks:
        return '🍔';
      case HappeningCategory.hangoutsSocial:
        return '🤝';
      case HappeningCategory.musicPerformance:
        return '🎵';
      case HappeningCategory.gamesActivities:
        return '🎮';
      case HappeningCategory.artCulture:
        return '🎨';
      case HappeningCategory.studyWork:
        return '📚';
      case HappeningCategory.popupsStreet:
        return '🔥';
    }
  }


  Color get color {
    switch (this) {
      case HappeningCategory.partyNightlife:
        return AppColors.categoryParty;
      case HappeningCategory.foodDrinks:
        return AppColors.categoryFood;
      case HappeningCategory.hangoutsSocial:
        return AppColors.categoryHangouts;
      case HappeningCategory.musicPerformance:
        return AppColors.categoryMusic;
      case HappeningCategory.gamesActivities:
        return AppColors.categoryGames;
      case HappeningCategory.artCulture:
        return AppColors.categoryArt;
      case HappeningCategory.studyWork:
        return AppColors.categoryStudy;
      case HappeningCategory.popupsStreet:
        return AppColors.categoryPopups;
    }
  }
}


enum HappeningType {
  event('event'),
  casual('casual');

  const HappeningType(this.value);


  final String value;


  static HappeningType? fromString(String? value) {
    if (value == null) return null;
    for (final type in HappeningType.values) {
      if (type.value == value) return type;
    }
    return null;
  }


  String get displayName {
    switch (this) {
      case HappeningType.event:
        return 'Official Event';
      case HappeningType.casual:
        return 'Casual Happening';
    }
  }
}


enum HappeningStatus {
  active('active'),
  expired('expired'),
  hidden('hidden'),
  reported('reported'),
  completed('completed');

  const HappeningStatus(this.value);


  final String value;


  static HappeningStatus? fromString(String? value) {
    if (value == null) return null;
    for (final status in HappeningStatus.values) {
      if (status.value == value) return status;
    }
    return null;
  }
}


enum ActivityLevel {
  low('low'),
  medium('medium'),
  high('high');

  const ActivityLevel(this.value);


  final String value;


  static ActivityLevel fromString(String? value) {
    if (value == null) return ActivityLevel.low;
    for (final level in ActivityLevel.values) {
      if (level.value == value) return level;
    }
    return ActivityLevel.low;
  }


  Color get color {
    switch (this) {
      case ActivityLevel.low:
        return AppColors.activityLow;
      case ActivityLevel.medium:
        return AppColors.activityMedium;
      case ActivityLevel.high:
        return AppColors.activityHigh;
    }
  }
}


enum TicketStatus {
  pending('pending'),
  paid('paid'),
  refundProcessing('refund_processing'),
  refunded('refunded');

  const TicketStatus(this.value);


  final String value;


  static TicketStatus? fromString(String? value) {
    if (value == null) return null;
    for (final status in TicketStatus.values) {
      if (status.value == value) return status;
    }
    return null;
  }


  String get displayName {
    switch (this) {
      case TicketStatus.pending:
        return 'Pending';
      case TicketStatus.paid:
        return 'Paid';
      case TicketStatus.refundProcessing:
        return 'Refund Processing';
      case TicketStatus.refunded:
        return 'Refunded';
    }
  }


  Color get color {
    switch (this) {
      case TicketStatus.pending:
        return AppColors.warning;
      case TicketStatus.paid:
        return AppColors.success;
      case TicketStatus.refundProcessing:
        return AppColors.warning;
      case TicketStatus.refunded:
        return AppColors.textSecondary;
    }
  }
}


enum EscrowStatus {
  collecting('collecting'),
  held('held'),
  awaitingCompletion('awaiting_completion'),
  released('released'),
  refunding('refunding'),
  refunded('refunded'),
  disputed('disputed');

  const EscrowStatus(this.value);


  final String value;


  static EscrowStatus? fromString(String? value) {
    if (value == null) return null;
    for (final status in EscrowStatus.values) {
      if (status.value == value) return status;
    }
    return null;
  }


  String get displayName {
    switch (this) {
      case EscrowStatus.collecting:
        return 'Collecting';
      case EscrowStatus.held:
        return 'Held';
      case EscrowStatus.awaitingCompletion:
        return 'Awaiting Completion';
      case EscrowStatus.released:
        return 'Released';
      case EscrowStatus.refunding:
        return 'Refunding';
      case EscrowStatus.refunded:
        return 'Refunded';
      case EscrowStatus.disputed:
        return 'Disputed';
    }
  }


  Color get color {
    switch (this) {
      case EscrowStatus.collecting:
        return AppColors.cyan;
      case EscrowStatus.held:
        return AppColors.warning;
      case EscrowStatus.awaitingCompletion:
        return AppColors.purple;
      case EscrowStatus.released:
        return AppColors.success;
      case EscrowStatus.refunding:
        return AppColors.warning;
      case EscrowStatus.refunded:
        return AppColors.textSecondary;
      case EscrowStatus.disputed:
        return AppColors.error;
    }
  }
}


enum PaymentGateway {
  paystack('paystack'),
  flutterwave('flutterwave');

  const PaymentGateway(this.value);


  final String value;


  static PaymentGateway? fromString(String? value) {
    if (value == null) return null;
    for (final gateway in PaymentGateway.values) {
      if (gateway.value == value) return gateway;
    }
    return null;
  }


  String get displayName {
    switch (this) {
      case PaymentGateway.paystack:
        return 'Paystack';
      case PaymentGateway.flutterwave:
        return 'Flutterwave';
    }
  }
}


enum VerificationStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected');

  const VerificationStatus(this.value);


  final String value;


  static VerificationStatus? fromString(String? value) {
    if (value == null) return null;
    for (final status in VerificationStatus.values) {
      if (status.value == value) return status;
    }
    return null;
  }


  String get displayName {
    switch (this) {
      case VerificationStatus.pending:
        return 'Pending';
      case VerificationStatus.approved:
        return 'Approved';
      case VerificationStatus.rejected:
        return 'Rejected';
    }
  }


  Color get color {
    switch (this) {
      case VerificationStatus.pending:
        return AppColors.warning;
      case VerificationStatus.approved:
        return AppColors.success;
      case VerificationStatus.rejected:
        return AppColors.error;
    }
  }
}


enum HostType {
  verified('verified'),
  community('community');

  const HostType(this.value);


  final String value;


  static HostType? fromString(String? value) {
    if (value == null) return null;
    for (final type in HostType.values) {
      if (type.value == value) return type;
    }
    return null;
  }


  String get displayName {
    switch (this) {
      case HostType.verified:
        return 'Verified Host';
      case HostType.community:
        return 'Community Host';
    }
  }
}


enum VerificationDocumentType {
  cac('cac'),
  instagram('instagram'),
  website('website');

  const VerificationDocumentType(this.value);


  final String value;


  static VerificationDocumentType? fromString(String? value) {
    if (value == null) return null;
    for (final type in VerificationDocumentType.values) {
      if (type.value == value) return type;
    }
    return null;
  }


  String get displayName {
    switch (this) {
      case VerificationDocumentType.cac:
        return 'CAC Registration';
      case VerificationDocumentType.instagram:
        return 'Instagram Page';
      case VerificationDocumentType.website:
        return 'Website URL';
    }
  }
}


enum EscrowAction {
  created('created'),
  ticketAdded('ticket_added'),
  ticketRefunded('ticket_refunded'),
  hostMarkedComplete('host_marked_complete'),
  adminApproved('admin_approved'),
  adminRejected('admin_rejected'),
  fundsReleased('funds_released'),
  refundInitiated('refund_initiated'),
  refundCompleted('refund_completed'),
  adminOverride('admin_override'),
  eventStarted('event_started');

  const EscrowAction(this.value);


  final String value;


  static EscrowAction? fromString(String? value) {
    if (value == null) return null;
    for (final action in EscrowAction.values) {
      if (action.value == value) return action;
    }
    return null;
  }


  String get displayName {
    switch (this) {
      case EscrowAction.created:
        return 'Escrow Created';
      case EscrowAction.ticketAdded:
        return 'Ticket Added';
      case EscrowAction.ticketRefunded:
        return 'Ticket Refunded';
      case EscrowAction.hostMarkedComplete:
        return 'Host Marked Complete';
      case EscrowAction.adminApproved:
        return 'Admin Approved';
      case EscrowAction.adminRejected:
        return 'Admin Rejected';
      case EscrowAction.fundsReleased:
        return 'Funds Released';
      case EscrowAction.refundInitiated:
        return 'Refund Initiated';
      case EscrowAction.refundCompleted:
        return 'Refund Completed';
      case EscrowAction.adminOverride:
        return 'Admin Override';
      case EscrowAction.eventStarted:
        return 'Event Started';
    }
  }
}

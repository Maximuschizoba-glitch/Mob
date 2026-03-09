import 'package:equatable/equatable.dart';

import '../../domain/entities/happening.dart';


abstract class FeedState extends Equatable {
  const FeedState();

  @override
  List<Object?> get props => [];
}


class FeedInitial extends FeedState {
  const FeedInitial();
}


class FeedLoading extends FeedState {
  const FeedLoading();
}


class FeedLoaded extends FeedState {

  final List<Happening> happenings;


  final bool hasMore;


  final int currentPage;


  final String? activeCategory;


  final bool isLoadingMore;

  const FeedLoaded({
    required this.happenings,
    required this.hasMore,
    required this.currentPage,
    this.activeCategory,
    this.isLoadingMore = false,
  });


  FeedLoaded copyWith({
    List<Happening>? happenings,
    bool? hasMore,
    int? currentPage,
    String? activeCategory,
    bool? isLoadingMore,
  }) {
    return FeedLoaded(
      happenings: happenings ?? this.happenings,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      activeCategory: activeCategory ?? this.activeCategory,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        happenings,
        hasMore,
        currentPage,
        activeCategory,
        isLoadingMore,
      ];
}


class FeedRefreshing extends FeedState {
  const FeedRefreshing();
}


class FeedError extends FeedState {

  final String message;


  final List<Happening>? previousHappenings;

  const FeedError(
    this.message, {
    this.previousHappenings,
  });

  @override
  List<Object?> get props => [message, previousHappenings];
}


class FeedEmpty extends FeedState {
  const FeedEmpty();
}

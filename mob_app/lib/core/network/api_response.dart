

class ApiResponse<T> {

  final bool success;


  final String message;


  final T? data;


  final PaginationMeta? meta;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.meta,
  });


  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic json)? fromJson,
  }) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromJson != null
          ? fromJson(json['data'])
          : json['data'] as T?,
      meta: json['meta'] != null
          ? PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
    );
  }


  bool get isPaginated => meta != null;


  bool get hasMorePages =>
      meta != null && meta!.currentPage < meta!.lastPage;

  @override
  String toString() =>
      'ApiResponse(success: $success, message: $message, hasData: ${data != null}, meta: $meta)';
}


class PaginationMeta {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  const PaginationMeta({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      lastPage: json['last_page'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'per_page': perPage,
        'total': total,
        'last_page': lastPage,
      };

  @override
  String toString() =>
      'PaginationMeta(page: $currentPage/$lastPage, perPage: $perPage, total: $total)';
}

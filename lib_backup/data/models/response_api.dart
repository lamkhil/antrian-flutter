class ResponseApi<T> {
  final T? data;
  final PaginationMeta? pagination;
  final String? message;
  final bool success;

  ResponseApi({this.data, this.pagination, this.message, this.success = true});

  factory ResponseApi.fromJson(
    Map<String, dynamic> json, {
    Function(dynamic json)? data,
    T? list,
  }) {
    // Laravel paginator
    if (json.containsKey('current_page') && json.containsKey('data')) {
      return ResponseApi(
        data: list,
        pagination: PaginationMeta.fromJson(json),
        success: true,
      );
    }

    // List biasa
    if (json['data'] is List) {
      return ResponseApi(data: list, success: true);
    }

    // Single object
    return ResponseApi(
      data: json['data'] != null ? data!(json['data']) : null,
      message: json['message'],
      success: json['success'] ?? true,
    );
  }

  factory ResponseApi.error(String message) {
    return ResponseApi(message: message, success: false);
  }
}

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final String? nextPageUrl;
  final String? prevPageUrl;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      perPage: json['per_page'],
      total: json['total'],
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
    );
  }

  bool get hasNext => nextPageUrl != null;
}

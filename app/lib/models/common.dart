class PaginationMetadata {
  int page;
  int limit;
  int total;

  PaginationMetadata({this.page = 1, this.limit = 10, required this.total});

  factory PaginationMetadata.fromJson(Map<String, dynamic> json) {
    return PaginationMetadata(
        page: json['page'], limit: json['limit'], total: json['total']);
  }
}

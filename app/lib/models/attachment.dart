class Attachment {
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? userId;
  String? itemId;
  String? path;

  Attachment({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.itemId,
    this.path,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      userId: json['user_id'],
      itemId: json['item_id'],
      path: json['path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user_id': userId,
      'item_id': itemId,
      'path': path,
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

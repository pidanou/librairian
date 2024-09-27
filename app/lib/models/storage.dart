class Location {
  String id;
  DateTime? createdAt;
  DateTime? updatedAt;
  String userId;
  String itemId;
  Storage? storage;
  String storageId;
  bool picked;

  Location({
    this.id = "",
    this.createdAt,
    this.updatedAt,
    this.userId = "",
    this.itemId = "",
    this.storage,
    this.storageId = "",
    this.picked = false,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      userId: json['user_id'],
      itemId: json['item_id'],
      storage: Storage.fromJson(json['storage']),
      storageId: json['storage_id'],
      picked: json['picked'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (id.isNotEmpty) data['id'] = id;
    if (createdAt != null) data['created_at'] = createdAt?.toIso8601String();
    if (updatedAt != null) data['updated_at'] = updatedAt?.toIso8601String();
    if (userId.isNotEmpty) data['user_id'] = userId;
    if (itemId.isNotEmpty) data['item_id'] = itemId;
    if (storage != null) data['storage'] = storage?.toJson();
    if (storageId.isNotEmpty) data['storage_id'] = storageId;

    data['picked'] = picked;

    return data;
  }

  @override
  String toString() => toJson().toString();
}

class Storage {
  String id;
  DateTime? createdAt;
  DateTime? updatedAt;
  String userId;
  String alias;

  Storage({
    this.id = "",
    this.createdAt,
    this.updatedAt,
    this.userId = "",
    this.alias = "",
  });

  factory Storage.fromJson(Map<String, dynamic> json) {
    return Storage(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      userId: json['user_id'],
      alias: json['alias'],
    );
  }

  Map<String, dynamic> toJson() {
    if (id == "") {
      return {
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'user_id': userId,
        'alias': alias,
      };
    }
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user_id': userId,
      'alias': alias,
    };
  }
}

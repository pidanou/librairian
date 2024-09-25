class Location {
  String id;
  DateTime? createdAt;
  DateTime? updatedAt;
  String userId;
  String itemId;
  Storage? storage;
  String storageId;
  String location;
  bool picked;

  Location({
    this.id = "",
    this.createdAt,
    this.updatedAt,
    this.userId = "",
    this.itemId = "",
    this.storage,
    this.storageId = "",
    this.location = "",
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
      location: json['location'],
      picked: json['picked'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user_id': userId,
      'item_id': itemId,
      'storage': storage?.toJson(),
      'storage_id': storageId,
      'location': location,
      'picked': picked,
    };
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

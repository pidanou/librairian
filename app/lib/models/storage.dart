class Location {
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? userId;
  String? fileId;
  Storage? storage;
  String? storageId;
  String? location;

  Location({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.fileId,
    this.storage,
    this.storageId,
    this.location,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      userId: json['user_id'],
      fileId: json['file_id'],
      storage: Storage.fromJson(json['storage']),
      storageId: json['storage_id'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user_id': userId,
      'file_id': fileId,
      'storage': storage?.toJson(),
      'storage_id': storageId,
      'location': location,
    };
  }

  @override
  String toString() => toJson().toString();
}

class Storage {
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? userId;
  String? type;
  String? alias;
  String? username;

  Storage({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.alias,
    this.username,
  });

  factory Storage.fromJson(Map<String, dynamic> json) {
    return Storage(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      userId: json['user_id'],
      alias: json['alias'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user_id': userId,
      'type': type,
      'alias': alias,
      'username': username,
    };
  }
}

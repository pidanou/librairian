import 'package:cross_file/cross_file.dart';
import 'package:librairian/models/storage.dart';

class File {
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? userId;
  String? name;
  DateTime? analysisDate;
  Description? description;
  List<StorageLocation>? storageLocations;
  List<String>? tags;
  int? size;
  int? wordCount;

  File({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.name,
    this.analysisDate,
    this.description,
    this.storageLocations,
    this.tags,
    this.size,
    this.wordCount,
  });

  @override
  String toString() {
    return toJson().toString();
  }

  static Future<File> fromXFile(XFile xfile) async {
    return File(
        name: xfile.name,
        storageLocations: [StorageLocation(location: xfile.path)],
        size: await xfile.length());
  }

  factory File.fromJson(Map<String, dynamic> json) {
    return File(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      userId: json['user_id'],
      name: json['name'],
      analysisDate: json['analysis_date'] != null
          ? DateTime.parse(json['analysis_date'])
          : null,
      description: json['description'] != null
          ? Description.fromJson(json['description'])
          : null,
      storageLocations: (json['storage_locations'] as List)
          .map((e) => StorageLocation.fromJson(e))
          .toList(),
      tags: List<String>.from(json['tags']),
      size: json['size'],
      wordCount: json['word_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'analysis_date': analysisDate?.toIso8601String(),
      'description': description?.toJson(),
      'storage_locations': storageLocations?.map((e) => e.toJson()).toList(),
      'tags': tags,
      'size': size,
      'word_count': wordCount,
    };
  }
}

class Description {
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  String userId;
  String? fileId;
  String data;
  // Assuming `embedding` is not needed as it is not included in JSON serialization

  Description({
    this.id,
    this.createdAt,
    this.updatedAt,
    required this.userId,
    this.fileId,
    required this.data,
  });

  factory Description.fromJson(Map<String, dynamic> json) {
    return Description(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      userId: json['user_id'],
      fileId: json['file_id'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user_id': userId,
      'file_id': fileId,
      'data': data,
    };
  }
}

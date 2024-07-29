import 'package:cross_file/cross_file.dart';
import 'package:librairian/models/storage.dart';
import 'package:librairian/models/common.dart';

class PaginatedItemsList {
  List<Item> data;
  PaginationMetadata metadata;

  PaginatedItemsList({required this.data, required this.metadata});

  factory PaginatedItemsList.fromJson(Map<String, dynamic> json) {
    return PaginatedItemsList(
        data: (json['data'] as List).map((e) => Item.fromJson(e)).toList(),
        metadata: PaginationMetadata.fromJson(json["metadata"]));
  }

  @override
  toString() {
    return data.toString();
  }
}

class Item {
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? userId;
  String? name;
  bool? isDigital;
  DateTime? analysisDate;
  Description? description;
  List<StorageLocation>? storageLocations;
  int? size;
  int? wordCount;

  Item({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.name,
    required this.isDigital,
    this.analysisDate,
    this.description,
    this.storageLocations,
  });

  @override
  String toString() {
    return toJson().toString();
  }

  static newPhysicalItem() {
    return Item(isDigital: false, name: 'New Item');
  }

  static Future<Item> fromXFile(XFile xfile) async {
    return Item(
      name: xfile.name,
      isDigital: true,
      storageLocations: [StorageLocation(location: xfile.path)],
    );
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      userId: json['user_id'],
      name: json['name'],
      isDigital: json['is_digital'],
      analysisDate: json['analysis_date'] != null
          ? DateTime.parse(json['analysis_date'])
          : null,
      description: json['description'] != null
          ? Description.fromJson(json['description'])
          : null,
      storageLocations: (json['storage_locations'] as List)
          .map((e) => StorageLocation.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'is_digital': isDigital,
      'analysis_date': analysisDate?.toIso8601String(),
      'description': description?.toJson(),
      'storage_locations': storageLocations?.map((e) => e.toJson()).toList(),
    };
  }
}

class Description {
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  String userId;
  String? itemId;
  String data;
  // Assuming `embedding` is not needed as it is not included in JSON serialization

  Description({
    this.id,
    this.createdAt,
    this.updatedAt,
    required this.userId,
    this.itemId,
    required this.data,
  });

  factory Description.fromJson(Map<String, dynamic> json) {
    return Description(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      userId: json['user_id'],
      itemId: json['item_id'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user_id': userId,
      'item_id': itemId,
      'data': data,
    };
  }
}

class MatchItem {
  Item? item;
  double descriptionSimilarity;

  MatchItem({
    this.item,
    required this.descriptionSimilarity,
  });

  factory MatchItem.fromJson(Map<String, dynamic> json) {
    return MatchItem(
      item: json['item'] != null ? Item.fromJson(json['item']) : null,
      descriptionSimilarity: json['description_similarity'].toDouble(),
    );
  }
}

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
  String id;
  DateTime? createdAt;
  DateTime? updatedAt;
  String userId;
  String name;
  String description;
  List<Location>? locations;
  List<String>? attachments;

  Item({
    this.id = "",
    this.createdAt,
    this.updatedAt,
    this.userId = "",
    this.name = "",
    this.description = "",
    this.locations,
    this.attachments,
  });

  @override
  String toString() {
    return toJson().toString();
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      updatedAt: DateTime.parse(json['updated_at']).toLocal(),
      userId: json['user_id'],
      name: json['name'],
      description: json['description'],
      locations: (json['locations'] as List?)
              ?.map((e) => Location.fromJson(e))
              .toList() ??
          [],
      attachments:
          (json['attachments'] as List?)?.map((e) => e.toString()).toList() ??
              [],
    );
  }

  Map<String, dynamic> toJson() {
    if (id == "") {
      return {
        'user_id': userId,
        'name': name,
        'description': description,
      };
    }
    return {
      'id': id,
      'user_id': userId,
      if (name.isNotEmpty) 'name': name,
      if (description.isNotEmpty) 'description': description,
    };
  }
}

class MatchItem {
  Item? item;
  double similarity;

  MatchItem({
    this.item,
    required this.similarity,
  });

  factory MatchItem.fromJson(Map<String, dynamic> json) {
    return MatchItem(
      item: json['item'] != null ? Item.fromJson(json['item']) : null,
      similarity: json['similarity']?.toDouble(),
    );
  }
}

import 'package:json_annotation/json_annotation.dart';

part 'data_source.g.dart';

class DataSourcePayload {
  final String? event;
  final List<DataSourceResult> items;

  DataSourcePayload({this.event, required this.items});
  Map<String, dynamic> toJson() => {
    'event': event,
    'items': items.map((item) => item.toJson()).toList(),
  };
}

abstract class DataSourceResult {
  DataSourceResult();
  Map<String, dynamic> toJson();
}

@JsonSerializable()
class Item implements DataSourceResult {
  final bool? disabled;
  final String? label;
  final String value;

  Item({this.disabled, this.label, required this.value});

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ItemToJson(this);
}

@JsonSerializable()
class ItemGroup implements DataSourceResult {
  final String label;
  final List<Item> children;

  ItemGroup({required this.label, required this.children});

  factory ItemGroup.fromJson(Map<String, dynamic> json) =>
      _$ItemGroupFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ItemGroupToJson(this);
}

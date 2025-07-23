// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_source.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Item _$ItemFromJson(Map<String, dynamic> json) => Item(
  disabled: json['disabled'] as bool?,
  label: json['label'] as String?,
  value: json['value'] as String,
);

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
  'disabled': instance.disabled,
  'label': instance.label,
  'value': instance.value,
};

ItemGroup _$ItemGroupFromJson(Map<String, dynamic> json) => ItemGroup(
  label: json['label'] as String,
  children:
      (json['children'] as List<dynamic>)
          .map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$ItemGroupToJson(ItemGroup instance) => <String, dynamic>{
  'label': instance.label,
  'children': instance.children,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegistrationInfo _$RegistrationInfoFromJson(Map<String, dynamic> json) =>
    RegistrationInfo(
      application: Application.fromJson(
        json['application'] as Map<String, dynamic>,
      ),
      colors: Colors.fromJson(json['colors'] as Map<String, dynamic>),
      devicePixelRatio: (json['devicePixelRatio'] as num).toDouble(),
      devices:
          (json['devices'] as List<dynamic>)
              .map((e) => Device.fromJson(e as Map<String, dynamic>))
              .toList(),
      plugin: Plugin.fromJson(json['plugin'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RegistrationInfoToJson(RegistrationInfo instance) =>
    <String, dynamic>{
      'application': instance.application,
      'colors': instance.colors,
      'devicePixelRatio': instance.devicePixelRatio,
      'devices': instance.devices,
      'plugin': instance.plugin,
    };

Application _$ApplicationFromJson(Map<String, dynamic> json) => Application(
  font: json['font'] as String,
  language: json['language'] as String,
  platform: json['platform'] as String,
  platformVersion: json['platformVersion'] as String,
  version: json['version'] as String,
);

Map<String, dynamic> _$ApplicationToJson(Application instance) =>
    <String, dynamic>{
      'font': instance.font,
      'language': instance.language,
      'platform': instance.platform,
      'platformVersion': instance.platformVersion,
      'version': instance.version,
    };

Colors _$ColorsFromJson(Map<String, dynamic> json) => Colors(
  buttonMouseOverBackgroundColor:
      json['buttonMouseOverBackgroundColor'] as String,
  buttonPressedBackgroundColor: json['buttonPressedBackgroundColor'] as String,
  buttonPressedBorderColor: json['buttonPressedBorderColor'] as String,
  buttonPressedTextColor: json['buttonPressedTextColor'] as String,
  highlightColor: json['highlightColor'] as String,
);

Map<String, dynamic> _$ColorsToJson(Colors instance) => <String, dynamic>{
  'buttonMouseOverBackgroundColor': instance.buttonMouseOverBackgroundColor,
  'buttonPressedBackgroundColor': instance.buttonPressedBackgroundColor,
  'buttonPressedBorderColor': instance.buttonPressedBorderColor,
  'buttonPressedTextColor': instance.buttonPressedTextColor,
  'highlightColor': instance.highlightColor,
};

Device _$DeviceFromJson(Map<String, dynamic> json) => Device(
  id: json['id'] as String,
  name: json['name'] as String,
  size: Size.fromJson(json['size'] as Map<String, dynamic>),
  type: json['type'] as String,
);

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'size': instance.size,
  'type': instance.type,
};

Size _$SizeFromJson(Map<String, dynamic> json) => Size(
  columns: (json['columns'] as num).toInt(),
  rows: (json['rows'] as num).toInt(),
);

Map<String, dynamic> _$SizeToJson(Size instance) => <String, dynamic>{
  'columns': instance.columns,
  'rows': instance.rows,
};

Plugin _$PluginFromJson(Map<String, dynamic> json) =>
    Plugin(uuid: json['uuid'] as String, version: json['version'] as String);

Map<String, dynamic> _$PluginToJson(Plugin instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'version': instance.version,
};

import 'package:json_annotation/json_annotation.dart';

part 'registration_info.g.dart';

@JsonSerializable()
class RegistrationInfo {
  final Application application;
  final Colors colors;
  final double devicePixelRatio;
  final List<Device> devices;
  final Plugin plugin;

  RegistrationInfo({
    required this.application,
    required this.colors,
    required this.devicePixelRatio,
    required this.devices,
    required this.plugin,
  });

  factory RegistrationInfo.fromJson(Map<String, dynamic> json) =>
      _$RegistrationInfoFromJson(json);
  Map<String, dynamic> toJson() => _$RegistrationInfoToJson(this);
}

@JsonSerializable()
class Application {
  final String font;
  final String language;
  final String platform;
  final String platformVersion;
  final String version;

  Application({
    required this.font,
    required this.language,
    required this.platform,
    required this.platformVersion,
    required this.version,
  });

  factory Application.fromJson(Map<String, dynamic> json) =>
      _$ApplicationFromJson(json);
  Map<String, dynamic> toJson() => _$ApplicationToJson(this);
}

@JsonSerializable()
class Colors {
  final String buttonMouseOverBackgroundColor;
  final String buttonPressedBackgroundColor;
  final String buttonPressedBorderColor;
  final String buttonPressedTextColor;
  final String highlightColor;

  Colors({
    required this.buttonMouseOverBackgroundColor,
    required this.buttonPressedBackgroundColor,
    required this.buttonPressedBorderColor,
    required this.buttonPressedTextColor,
    required this.highlightColor,
  });

  factory Colors.fromJson(Map<String, dynamic> json) => _$ColorsFromJson(json);
  Map<String, dynamic> toJson() => _$ColorsToJson(this);
}

@JsonSerializable()
class Device {
  final String id;
  final String name;
  final Size size;
  final String type;

  Device({
    required this.id,
    required this.name,
    required this.size,
    required this.type,
  });

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);
  Map<String, dynamic> toJson() => _$DeviceToJson(this);
}

@JsonSerializable()
class Size {
  final int columns;
  final int rows;

  Size({required this.columns, required this.rows});

  factory Size.fromJson(Map<String, dynamic> json) => _$SizeFromJson(json);
  Map<String, dynamic> toJson() => _$SizeToJson(this);
}

@JsonSerializable()
class Plugin {
  final String uuid;
  final String version;

  Plugin({required this.uuid, required this.version});

  factory Plugin.fromJson(Map<String, dynamic> json) => _$PluginFromJson(json);
  Map<String, dynamic> toJson() => _$PluginToJson(this);
}

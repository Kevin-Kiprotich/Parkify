class GeoJsonModel {
  GeoJsonModel({required this.type, required this.features});
  final String type;
  final List<Map<String, dynamic>> features;

  Map<String, dynamic> toJson() => {
        'type': type,
        'features': features,
      };
  factory GeoJsonModel.fromJson(Map<String, dynamic> json) {
    return GeoJsonModel(
      type: json['type'],
      features: List<Map<String, dynamic>>.from(json['features']),
    );
  }
}

class Weather {
  final String cityName;
  final double temperature; // Suhu (dalam Kelvin)
  final String mainCondition; // Misal: "Clouds", "Rain"
  final String description; // Misal: "overcast clouds"
  final String icon; // Kode ikon cuaca

  Weather({
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
    required this.description,
    required this.icon,
  });

  // Helper (getter) untuk mengubah Kelvin ke Celsius
  double get temperatureInCelsius => temperature - 273.15;

  // Helper (getter) untuk mendapatkan URL ikon
  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';

  // Ini adalah bagian parsing JSON yang lebih kompleks (bersarang)
  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      // 'name' ada di level atas
      cityName: json['name'],

      // 'temp' ada di dalam Map 'main'
      temperature: json['main']['temp'],

      // 'main', 'description', dan 'icon' ada di dalam
      // List 'weather' di indeks ke-0
      mainCondition: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
    );
  }
}

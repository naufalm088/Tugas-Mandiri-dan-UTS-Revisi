import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'weather_model.dart'; // Impor model cuaca

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  // 1. GANTI DENGAN API KEY ANDA YANG ASLI
  final String _apiKey = "7745bedd0f23244cafe67dd0be1b2670";

  // 2. State untuk menyimpan "Future" dan nama kota
  late Future<Weather> _futureWeather;
  final _cityController = TextEditingController();
  String _cityName = "London"; // Kota default

  @override
  void initState() {
    super.initState();
    // 3. Ambil data cuaca untuk kota default saat aplikasi dibuka
    _futureWeather = _fetchWeather();
  }

  // 4. FUNGSI UNTUK MENGAMBIL DATA CUACA
  Future<Weather> _fetchWeather() async {
    // Bangun URL dengan nama kota dan API key
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$_cityName&appid=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Sukses, parse JSON dan ubah jadi objek Weather
      final dataJson = jsonDecode(response.body);
      return Weather.fromJson(dataJson);
    } else if (response.statusCode == 404) {
      throw Exception('Kota tidak ditemukan.');
    } else {
      // Gagal
      throw Exception('Gagal memuat data cuaca: ${response.statusCode}');
    }
  }

  // 5. FUNGSI UNTUK MEMULAI PENCARIAN BARU
  void _search() {
    if (_cityController.text.isNotEmpty) {
      setState(() {
        _cityName = _cityController.text;
        // Panggil ulang _fetchWeather() dengan kota baru
        // dan simpan "janji" baru ke _futureWeather
        _futureWeather = _fetchWeather();
      });
      _cityController.clear(); // Kosongkan field
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pencari Cuaca")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 6. UI UNTUK PENCARIAN
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: "Masukkan Nama Kota",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search, // Panggil fungsi search
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 7. FUTUREBUILDER UNTUK MENAMPILKAN HASIL
            Expanded(
              child: FutureBuilder<Weather>(
                future: _futureWeather, // Dengarkan "janji" ini
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Tampilkan loading
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    // Tampilkan error
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (snapshot.hasData) {
                    // SUKSES! Tampilkan data
                    final weather = snapshot.data!;
                    return _buildWeatherCard(weather);
                  } else {
                    return const Center(child: Text("Silakan cari kota"));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 8. WIDGET HELPER UNTUK MENAMPILKAN KARTU CUACA
  Widget _buildWeatherCard(Weather weather) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Agar kartu pas
          children: [
            // Nama Kota
            Text(
              weather.cityName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Ikon Cuaca
            Image.network(weather.iconUrl, scale: 0.7),
            const SizedBox(height: 10),

            // Suhu (dibulatkan 1 angka desimal)
            Text(
              '${weather.temperatureInCelsius.toStringAsFixed(1)}°C',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Kondisi Utama dan Deskripsi
            Text(
              '${weather.mainCondition} (${weather.description})',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

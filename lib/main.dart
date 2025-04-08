import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart'; // Import the calendar package
import 'splash_screen.dart'; // Import the splash screen

void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Start with the Splash Screen
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => SplashScreen());
          case '/home':
            return MaterialPageRoute(builder: (context) => HomeScreen());
          default:
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(child: Text('Page not found!')),
              ),
            );
        }
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String city = 'Mumbai'; // Default city
  double temperature = 0.0;
  String weatherDescription = 'Loading...';
  String weatherIcon = '☀';
  double windSpeed = 0.0;
  int humidity = 0;
  double lightHours = 0.0; // Total sunlight duration in hours
  String apiKey = '35ff160dfd0252e8171f4ab1776e7f1d'; // Replace with your API key
  bool isLoading = true;
  bool isDayTime = true;

  final TextEditingController _searchController = TextEditingController();
  DateTime selectedDate = DateTime.now(); // Track the selected date

  @override
  void initState() {
    super.initState();
    fetchWeatherData(city);
  }

  Future<void> fetchWeatherData(String cityName) async {
    setState(() {
      isLoading = true;
    });

    final url = 'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final sunrise = DateTime.fromMillisecondsSinceEpoch(data['sys']['sunrise'] * 1000);
        final sunset = DateTime.fromMillisecondsSinceEpoch(data['sys']['sunset'] * 1000);
        final int currentTime = DateTime.now().hour;

        setState(() {
          city = data['name']; // Update the city name with the fetched data
          temperature = data['main']['temp'];
          weatherDescription = data['weather'][0]['description'];
          weatherIcon = getWeatherIcon(data['weather'][0]['main'], temperature);
          windSpeed = data['wind']['speed'];
          humidity = data['main']['humidity'];
          lightHours = sunset.difference(sunrise).inHours.toDouble(); // Calculate light hours
          isDayTime = currentTime >= sunrise.hour && currentTime < sunset.hour;
        });
      } else {
        showErrorDialog('City not found. Please try again.');
      }
    } catch (e) {
      showErrorDialog('Network error. Please try again later.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  String getWeatherIcon(String weatherMain, double temperature) {
    if (weatherMain == "Clear") return '☀';
    if (weatherMain == "Clouds") return '☁';
    if (weatherMain == "Rain") return '🌧';
    if (temperature > 30) return '🔥';
    if (temperature > 20) return '🌤';
    if (temperature > 10) return '☁';
    return '❄';
  }

  List<Color> getBackgroundGradient() {
    return isDayTime
        ? [Colors.indigo.shade900, Colors.black87] // Darker daytime gradient
        : [Colors.black, Colors.black87]; // Dark background for night
  }

  Future<void> fetchWeatherForSelectedDate(DateTime selectedDate) async {
    // You can adjust the weather data fetching logic based on the selected date.
    // For simplicity, it's still fetching data for the current day.
    fetchWeatherData(city);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: getBackgroundGradient(),
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2101),
                        ).then((pickedDate) {
                          if (pickedDate != null && pickedDate != selectedDate) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                            fetchWeatherForSelectedDate(selectedDate);
                          }
                        });
                      },
                      child: Icon(Icons.calendar_today, color: Colors.white),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter city name',
                          hintStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        final newCity = _searchController.text;
                        if (newCity.isNotEmpty) {
                          fetchWeatherData(newCity);
                          _searchController.clear();
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.search, color: Colors.blueAccent),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      isLoading
                          ? Center(child: CircularProgressIndicator(color: Colors.white))
                          : Column(
                        children: [
                          AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Text(
                                  weatherIcon,
                                  style: TextStyle(fontSize: 80),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  '$city: ${temperature.toStringAsFixed(1)}°C', // Display city name with temperature
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  weatherDescription.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white70,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        Icon(Icons.air, color: Colors.white),
                                        Text('${windSpeed.toStringAsFixed(1)} m/s',
                                            style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                    SizedBox(width: 30),
                                    Column(
                                      children: [
                                        Icon(Icons.water_drop, color: Colors.white),
                                        Text('${humidity}%', style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                    SizedBox(width: 30),
                                    Column(
                                      children: [
                                        Icon(Icons.sunny, color: Colors.white),
                                        Text('${lightHours.toStringAsFixed(1)}Hrs ',
                                            style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Hourly Forecast',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            height: 120,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                HourlyForecastCard(time: 'Now', temperature: 29, icon: '🌧'),
                                HourlyForecastCard(time: '5pm', temperature: 28, icon: '🌤'),
                                HourlyForecastCard(time: '6pm', temperature: 28, icon: '☁'),
                                HourlyForecastCard(time: '7pm', temperature: 27, icon: '🌙'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HourlyForecastCard extends StatelessWidget {
  final String time;
  final double temperature;
  final String icon;

  HourlyForecastCard({required this.time, required this.temperature, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              time,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              '$temperature°C',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 6),
            Text(
              icon,
              style: TextStyle(
                fontSize: 24,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

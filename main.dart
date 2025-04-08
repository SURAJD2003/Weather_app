import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart'; // Import the calendar package
import 'splash_screen.dart'; // Import the splash screen

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Start with the Splash Screen
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
                builder: (context) => const SplashScreen());
          case '/home':
            return MaterialPageRoute(builder: (context) => const HomeScreen());
          default:
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
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
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  String city = 'Mumbai'; // Default city
  double temperature = 0.0;
  String weatherDescription = 'Loading...';
  String weatherIcon = '☀';
  double windSpeed = 0.0;
  int humidity = 0;
  double sunriseTime = 0.0; // in hours
  String apiKey =
      '35ff160dfd0252e8171f4ab1776e7f1d'; // Replace with your API key
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

    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final int currentTime = DateTime.now().hour;

        setState(() {
          city = cityName;
          temperature = data['main']['temp'];
          weatherDescription = data['weather'][0]['description'];
          weatherIcon = getWeatherIcon(data['weather'][0]['main'], temperature);
          windSpeed = data['wind']['speed'];
          humidity = data['main']['humidity'];
          sunriseTime = data['sys']['sunrise'] / 3600; // convert to hours
          isDayTime = currentTime >= 6 &&
              currentTime < 18; // Daytime logic (6:00 AM - 6:00 PM)
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
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
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

  // Fetch weather data for the selected date (In this example, it's still pulling current data for simplicity)
  Future<void> fetchWeatherForSelectedDate(DateTime selectedDate) async {
    // You can adjust the weather data fetching logic based on the selected date.
    // For simplicity, it's still fetching data for the current day.
    fetchWeatherData(city);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // Ensure the content doesn't overlap with system UI
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: getBackgroundGradient(),
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            // Allow scrolling to avoid overflow
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // Search Bar
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Calendar Button
                          GestureDetector(
                            onTap: () {
                              showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2101),
                              ).then((pickedDate) {
                                if (pickedDate != null &&
                                    pickedDate != selectedDate) {
                                  setState(() {
                                    selectedDate = pickedDate;
                                  });
                                  fetchWeatherForSelectedDate(selectedDate);
                                }
                              });
                            },
                            child: const Icon(Icons.calendar_today,
                                color: Colors.white),
                          ),
                          const SizedBox(width: 16),

                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Enter city name',
                                hintStyle:
                                    const TextStyle(color: Colors.white70),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              final newCity = _searchController.text;
                              if (newCity.isNotEmpty) {
                                fetchWeatherData(newCity);
                                _searchController.clear();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.search,
                                  color: Colors.blueAccent),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Weather Information
                  isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white))
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Text(
                                      weatherIcon,
                                      style: const TextStyle(fontSize: 80),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      '${temperature.toStringAsFixed(1)}°C',
                                      style: const TextStyle(
                                        fontSize: 40, // Reduced font size
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      weatherDescription.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          children: [
                                            const Icon(Icons.air,
                                                color:
                                                    Colors.white), // Wind icon
                                            Text(
                                                '${windSpeed.toStringAsFixed(1)} m/s',
                                                style: const TextStyle(
                                                    color: Colors.white)),
                                          ],
                                        ),
                                        const SizedBox(width: 30),
                                        Column(
                                          children: [
                                            const Icon(Icons.water_drop,
                                                color: Colors
                                                    .white), // Humidity icon
                                            Text('$humidity%',
                                                style: const TextStyle(
                                                    color: Colors.white)),
                                          ],
                                        ),
                                        const SizedBox(width: 30),
                                        Column(
                                          children: [
                                            const Icon(Icons.sunny,
                                                color: Colors
                                                    .white), // Sunrise icon
                                            Text(
                                                '${sunriseTime.toStringAsFixed(1)} hrs',
                                                style: const TextStyle(
                                                    color: Colors.white)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Hourly Forecast
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  'Hourly Forecast',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height:
                                    100, // Adjusted height for smaller cards
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: const [
                                    HourlyForecastCard(
                                        time: 'Now',
                                        temperature: 29,
                                        icon: '🌧'),
                                    HourlyForecastCard(
                                        time: '5pm',
                                        temperature: 28,
                                        icon: '🌤'),
                                    HourlyForecastCard(
                                        time: '6pm',
                                        temperature: 28,
                                        icon: '☁'),
                                    HourlyForecastCard(
                                        time: '7pm',
                                        temperature: 27,
                                        icon: '🌙'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
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

  const HourlyForecastCard(
      {super.key,
      required this.time,
      required this.temperature,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
            12), // Smaller border radius for rounded corners
      ),
      elevation: 4, // Added elevation for a subtle shadow effect
      margin: const EdgeInsets.symmetric(
          horizontal: 8), // Reduced margin for a compact look
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              time,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14, // Smaller font size for time
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$temperature°C',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16, // Slightly smaller font size for temperature
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              icon,
              style: const TextStyle(
                fontSize: 24, // Reduced icon size
                height: 1.5, // Adjusted icon spacing
              ),
            ),
          ],
        ),
      ),
    );
  }
}

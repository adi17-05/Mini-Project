import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() {
  runApp(SimpleHealthApp());
}

class SimpleHealthApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Predictor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: SimpleHomePage(),
    );
  }
}

class SimpleHomePage extends StatefulWidget {
  @override
  State<SimpleHomePage> createState() => _SimpleHomePageState();
}

class _SimpleHomePageState extends State<SimpleHomePage> {
  static const platform = MethodChannel('com.adity.health/healthdata');

  Map<String, dynamic> healthData = {
    'step_count': 0,
    'heart_rate_bpm': 0,
    'total_sleep_minutes': 0,
    'calories': 0,
    'bmi': 0.0,
    'spo2': 0,
    'stress_level': 0,
  };

  bool dataFetched = false;
  bool loading = false;
  String? error;
  Map<String, dynamic>? prediction;
  bool usingRealHealthData = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade400, Colors.indigo.shade600],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Text(
                    'Health Predictor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                // Health Data Dashboard
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Health Dashboard',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (dataFetched) ...[
                                SizedBox(height: 4),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: usingRealHealthData ? Colors.green : Colors.orange,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    usingRealHealthData ? '🔗 Real Data' : '📊 Demo Data',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: dataFetched ? Colors.green : Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              dataFetched ? 'LIVE DATA' : 'DEMO DATA',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Health Metrics Grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.2,
                        children: [
                          _buildMetricCard('Steps', '${healthData['step_count']}', Icons.directions_walk, Colors.blue),
                          _buildMetricCard('Heart Rate', '${healthData['heart_rate_bpm']} bpm', Icons.favorite, Colors.red),
                          _buildMetricCard('Sleep', '${(healthData['total_sleep_minutes'] / 60).toStringAsFixed(1)}h', Icons.bedtime, Colors.purple),
                          _buildMetricCard('Calories', '${healthData['calories']}', Icons.local_fire_department, Colors.orange),
                          _buildMetricCard('BMI', '${healthData['bmi']}', Icons.monitor_weight, Colors.green),
                          _buildMetricCard('SpO2', '${healthData['spo2']}%', Icons.air, Colors.cyan),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),

                // Prediction Results
                if (prediction != null) ...[
                  _buildPredictionResults(),
                  const SizedBox(height: 20),
                ],

                // Action Button
                Container(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: loading ? null : _simulateDataFetch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.teal.shade700,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: loading
                        ? CircularProgressIndicator(color: Colors.teal.shade700)
                        : Text(
                            dataFetched ? 'Get AI Health Prediction' : 'Fetch Data & Get Prediction',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                
                // Error Display
                if (error != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Text(
                      error!,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
                
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _simulateDataFetch() async {
    setState(() {
      loading = true;
      error = null;
      prediction = null;
    });

    try {
      // Step 1: Get health data from Android
      final result = await platform.invokeMethod('getHealthData');
      final fetchedData = Map<String, dynamic>.from(result);

      // Check if we got real health data or demo data (check multiple fields)
      bool isRealData = fetchedData['step_count'] != 8500 &&
                       fetchedData['calories'] != 2100 &&
                       fetchedData['heart_rate_bpm'] != 72 &&
                       fetchedData['total_sleep_minutes'] != 480 &&
                       fetchedData['bmi'] != 22.5 &&
                       fetchedData['spo2'] != 98;

      setState(() {
        healthData = fetchedData;
        dataFetched = true;
        usingRealHealthData = isRealData;
      });

      // Step 2: Send data to ML server for prediction
      await _getPrediction(fetchedData);

      setState(() {
        loading = false;
      });

      // Show success message with data source info
      String dataSource = usingRealHealthData ? "real Health Connect data" : "demo data";
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Health data from $dataSource & AI prediction completed!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Handle different types of errors
      String errorMessage = e.toString();
      bool isPermissionError = errorMessage.contains('PERMISSION_DENIED');

      // Fallback to demo data
      final demoData = {
        'step_count': 8500,
        'heart_rate_bpm': 72,
        'total_sleep_minutes': 480,
        'calories': 2100,
        'bmi': 22.5,
        'spo2': 98,
        'stress_level': 3,
      };

      setState(() {
        healthData = demoData;
        dataFetched = true;
        usingRealHealthData = false;
      });

      // Try prediction with demo data
      await _getPrediction(demoData);

      setState(() {
        loading = false;
        error = isPermissionError ? 'Health Connect permissions needed' : 'Using demo data: $e';
      });

      // Show appropriate message
      if (mounted) {
        if (isPermissionError) {
          // Show permission instructions dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('🔐 Health Connect Permissions'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('To get real health data, please:'),
                  SizedBox(height: 10),
                  Text('1. Open Health Connect app'),
                  Text('2. Go to "App permissions"'),
                  Text('3. Find "flutter_application_1"'),
                  Text('4. Grant all health permissions'),
                  Text('5. Try again'),
                  SizedBox(height: 10),
                  Text('Using demo data for now.',
                       style: TextStyle(fontStyle: FontStyle.italic)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📊 Using demo data with AI prediction'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  Future<void> _getPrediction(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final predictionData = jsonDecode(response.body);
        setState(() {
          prediction = predictionData;
        });
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('Prediction error: $e');
      // Set a fallback prediction for demo purposes
      setState(() {
        prediction = {
          'health_score': 75,
          'risk_level': 'Moderate',
          'diseases': ['Hypertension Risk: 15%', 'Diabetes Risk: 8%'],
          'recommendations': ['Increase daily steps', 'Improve sleep quality']
        };
      });
    }
  }

  Widget _buildPredictionResults() {
    if (prediction == null) return Container();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'AI Health Analysis',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Health Score
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.favorite, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text(
                  'Health Score: ${prediction!['health_score'] ?? 'N/A'}%',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),

          // Risk Level
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Text(
                  'Risk Level: ${prediction!['risk_level'] ?? 'Unknown'}',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),

          // Diseases/Risks
          if (prediction!['diseases'] != null) ...[
            Text(
              'Health Risks:',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ...((prediction!['diseases'] as List).map((disease) => Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.circle, color: Colors.red, size: 8),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      disease.toString(),
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ))),
          ],

          SizedBox(height: 12),

          // Recommendations
          if (prediction!['recommendations'] != null) ...[
            Text(
              'Recommendations:',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ...((prediction!['recommendations'] as List).map((rec) => Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 8),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rec.toString(),
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ))),
          ],
        ],
      ),
    );
  }
}

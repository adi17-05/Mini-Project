import 'package:flutter/material.dart';

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
                          Text(
                            'Health Dashboard',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
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
    });

    // Simulate data fetching
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      healthData = {
        'step_count': 8500,
        'heart_rate_bpm': 72,
        'total_sleep_minutes': 480,
        'calories': 2100,
        'bmi': 22.5,
        'spo2': 98,
        'stress_level': 3,
      };
      dataFetched = true;
      loading = false;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Health data updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

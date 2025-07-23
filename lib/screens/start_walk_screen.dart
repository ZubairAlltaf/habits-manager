import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartWalkScreen extends StatefulWidget {
  const StartWalkScreen({Key? key}) : super(key: key);

  @override
  _StartWalkScreenState createState() => _StartWalkScreenState();
}

class _StartWalkScreenState extends State<StartWalkScreen> {
  bool _isTracking = false;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  String _timerDisplay = "00:00:00";
  String _distanceDisplay = "0.00";
  String _paceDisplay = "0'00\"";

  StreamSubscription<Position>? _positionStream;
  Position? _lastPosition;
  double _sessionDistance = 0.0;
  double _totalDistance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTotalDistance();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionStream?.cancel();
    _saveTotalDistance();
    super.dispose();
  }

  Future<void> _loadTotalDistance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _totalDistance = prefs.getDouble('totalDistance') ?? 0.0;
        _distanceDisplay = _totalDistance.toStringAsFixed(2);
      });
    } catch (e) {
      print("Error loading total distance: $e");
      setState(() {
        _distanceDisplay = "0.00";
      });
    }
  }

  Future<void> _saveTotalDistance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('totalDistance', _totalDistance);
    } catch (e) {
      print("Error saving total distance: $e");
    }
  }

  void _toggleTracking() async {
    if (_isTracking) {
      _stopTimer();
      await _stopLocationTracking();
      setState(() {
        _totalDistance += _sessionDistance;
        _distanceDisplay = _totalDistance.toStringAsFixed(2);
        _saveTotalDistance();
        _sessionDistance = 0.0;
      });
    } else {
      await _startLocationTracking();
      _startTimer();
    }

    setState(() {
      _isTracking = !_isTracking;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _elapsed += Duration(seconds: 1);
          _timerDisplay = _formatDuration(_elapsed);

          if (_sessionDistance > 0) {
            double paceSecondsPerKm = _elapsed.inSeconds / (_sessionDistance / 1000);
            int min = (paceSecondsPerKm ~/ 60);
            int sec = (paceSecondsPerKm % 60).toInt();
            _paceDisplay = "$min'${sec.toString().padLeft(2, '0')}\"";
          }
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    if (mounted) {
      setState(() {
        _elapsed = Duration.zero;
        _timerDisplay = "00:00:00";
        _paceDisplay = "0'00\"";
      });
    }
  }

  Future<void> _startLocationTracking() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission required")),
        );
      }
      return;
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      if (mounted && _lastPosition != null) {
        double step = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        setState(() {
          _sessionDistance += step;
          _distanceDisplay = (_totalDistance + _sessionDistance / 1000).toStringAsFixed(2);
        });
      }
      _lastPosition = position;
    }, onError: (e) {
      print("Location error: $e");
    });
  }

  Future<void> _stopLocationTracking() async {
    await _positionStream?.cancel();
    _positionStream = null;
    _lastPosition = null;
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes % 60)}:${twoDigits(d.inSeconds % 60)}";
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Walk'),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Center(
                child: Lottie.asset(
                  'assets/lottie_files/walking_flamingo.json',
                  height: 180,
                  fit: BoxFit.contain,
                  repeat: true,
                  animate: true,
                ),
              ),
            ),
            const SizedBox(height: 30),

            Text(
              "Today's Distance",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.teal),
            ),
            const SizedBox(height: 8),
            Text(
              "$_distanceDisplay km",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            Text(
              _timerDisplay,
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn("Distance (km)", _distanceDisplay),
                _buildStatColumn("Avg. Pace", _paceDisplay),
              ],
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _toggleTracking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isTracking ? Colors.red.shade600 : Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _isTracking ? 'STOP' : 'START',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
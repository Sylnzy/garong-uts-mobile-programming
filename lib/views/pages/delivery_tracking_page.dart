import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';

class DeliveryTrackingPage extends StatefulWidget {
  final String orderId;
  final String driverName;

  const DeliveryTrackingPage({
    Key? key,
    required this.orderId,
    required this.driverName,
  }) : super(key: key);

  @override
  State<DeliveryTrackingPage> createState() => _DeliveryTrackingPageState();
}

class _DeliveryTrackingPageState extends State<DeliveryTrackingPage> {
  late Timer _timer;
  double _driverProgress = 0.0;
  final _random = Random();
  final MapController _mapController = MapController();

  // Malang coordinates for demo
  final LatLng _restaurantLocation = LatLng(
    -7.9666,
    112.6326,
  ); // Warung Garong (Demo)
  final LatLng _destinationLocation = LatLng(
    -7.9456,
    112.6156,
  ); // Delivery Location (Demo)
  late LatLng _driverLocation;

  // Route points for interpolation (simplified for demo)
  final List<LatLng> _routePoints = [];

  // Simulated delivery locations
  final List<Map<String, dynamic>> _locations = [
    {'name': 'Warung Garong', 'distance': '0 km'},
    {'name': 'Jl. Sumbersari', 'distance': '0.5 km'},
    {'name': 'Jl. Gajayana', 'distance': '1.2 km'},
    {'name': 'Jl. MT Haryono', 'distance': '2.3 km'},
    {'name': 'Alamat Pengiriman', 'distance': '3.5 km'},
  ];

  int _currentLocationIndex = 0;

  @override
  void initState() {
    super.initState();
    _driverLocation = _restaurantLocation;
    _generateRoutePoints();

    // Simulate driver movement
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _driverProgress += 0.02 + (_random.nextDouble() * 0.01);

          if (_driverProgress >= 1.0) {
            _driverProgress = 1.0;
            timer.cancel();
          }

          // Update driver location along the route
          _updateDriverLocation();

          // Update location indicator based on progress
          _currentLocationIndex =
              (_driverProgress * (_locations.length - 1)).floor();
          if (_currentLocationIndex >= _locations.length) {
            _currentLocationIndex = _locations.length - 1;
          }

          // Center map on driver occasionally
          if (_random.nextDouble() > 0.7) {
            try {
              // In newer versions of flutter_map (>=6.0.0), access zoom directly
              _mapController.move(_driverLocation, 15.0);
            } catch (e) {
              print('Map controller error: $e');
            }
          }
        });
      }
    });
  }

  void _generateRoutePoints() {
    // In a real app, you would fetch actual route points from a routing API
    // Here we're generating a simplified route between restaurant and destination

    // Add restaurant location
    _routePoints.add(_restaurantLocation);

    // Add some waypoints for a realistic route (simplified demo)
    _routePoints.add(LatLng(-7.9620, 112.6290)); // Waypoint 1
    _routePoints.add(LatLng(-7.9580, 112.6250)); // Waypoint 2
    _routePoints.add(LatLng(-7.9520, 112.6200)); // Waypoint 3
    _routePoints.add(LatLng(-7.9480, 112.6170)); // Waypoint 4

    // Add destination
    _routePoints.add(_destinationLocation);
  }

  void _updateDriverLocation() {
    if (_routePoints.length < 2) return;

    // Calculate which segment the driver is in
    final segmentCount = _routePoints.length - 1;
    final segmentIndex = min(
      (segmentCount * _driverProgress).floor(),
      segmentCount - 1,
    );
    final segmentProgress = (segmentCount * _driverProgress) - segmentIndex;

    // Get the current segment's start and end points
    final start = _routePoints[segmentIndex];
    final end = _routePoints[segmentIndex + 1];

    // Interpolate position along the segment
    final lat =
        start.latitude + (end.latitude - start.latitude) * segmentProgress;
    final lng =
        start.longitude + (end.longitude - start.longitude) * segmentProgress;

    _driverLocation = LatLng(lat, lng);
  }

  @override
  void dispose() {
    _timer.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remainingTime = (20 - (_driverProgress * 20)).ceil();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lacak Pengiriman"),
        backgroundColor: const Color(0xFF0F1C2E),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Driver info header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF0F1C2E),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pesanan #${widget.orderId}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.delivery_dining,
                        color: Color(0xFF0F1C2E),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Driver: ${widget.driverName}",
                            style: const TextStyle(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Tiba dalam ${remainingTime} menit",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.my_location, color: Colors.white),
                      onPressed: () => _mapController.move(_driverLocation, 15),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Map view
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _driverLocation,
                initialZoom: 15,
                maxZoom: 18,
                minZoom: 13,
              ),
              children: [
                // Base map layer
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                  subdomains: const ['a', 'b', 'c'],
                ),

                // Route polyline
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: const Color(0xFF0F1C2E),
                      strokeWidth: 4.0,
                    ),
                  ],
                ),

                // Markers
                MarkerLayer(
                  markers: [
                    // Restaurant marker
                    Marker(
                      point: _restaurantLocation,
                      width: 40,
                      height: 40,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                            child: const Icon(
                              Icons.restaurant,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Warung',
                              style: TextStyle(fontSize: 8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Destination marker
                    Marker(
                      point: _destinationLocation,
                      width: 40,
                      height: 40,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            child: const Icon(
                              Icons.home,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Tujuan',
                              style: TextStyle(fontSize: 8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Driver marker
                    Marker(
                      point: _driverLocation,
                      width: 50,
                      height: 50,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0F1C2E),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.delivery_dining,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Progress and location info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _locations[_currentLocationIndex]['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      _locations[_currentLocationIndex]['distance'],
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _driverProgress,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF0F1C2E),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Tiba dalam ${remainingTime} menit",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Berikan Feedback'),
                                content: TextField(
                                  maxLines: 3,
                                  decoration: const InputDecoration(
                                    hintText:
                                        'Berikan komentar tentang pengiriman...',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('BATAL'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Terima kasih atas feedback Anda!',
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0F1C2E),
                                    ),
                                    child: const Text('KIRIM'),
                                  ),
                                ],
                              ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F1C2E),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Berikan Feedback'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

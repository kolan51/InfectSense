import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
// Ensure the correct package is imported

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final MapController _mapController = MapController();
  final LatLng _hospitalLocation = LatLng(45.931867, 13.640821);
  bool isDeviceConnected = false;
  bool isWoundInfected = false;
  bool flashRed = false;

  @override
  void _navigateToProfile() {
    Navigator.pushNamed(context, '/profile');
  }

  @override
  void initState() {
    super.initState();
  }

  void _toggleDeviceConnection() {
    setState(() {
      isDeviceConnected = !isDeviceConnected;
      if (!isDeviceConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "The Device was disconnected please check the connection.",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "The Device is Connected.",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void _toggleWoundInfected() {
    setState(() {
      isWoundInfected = !isWoundInfected;

      if (isWoundInfected && isDeviceConnected) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                bool flash = true;
                Timer.periodic(const Duration(milliseconds: 500), (timer) {
                  setState(() {
                    flash = !flash;
                  });
                });

                Future.delayed(const Duration(seconds: 5), () {
                  Navigator.of(context).pop(); // Auto-close after 5 seconds
                  _mapController.move(_hospitalLocation, 15.0);
                });

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  color: flash ? Colors.redAccent : Colors.red.shade200,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warning,
                          color: Colors.white,
                          size: 100,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "WOUND INFECTED!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            "Please seek medical attention immediately.\nThe nearest hospital has been marked.",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: flashRed ? Colors.red.shade100 : const Color(0xFFD5F3ED),
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.red,
        elevation: 0,
        title: Image.asset(
          'assets/infecta.png',
          color: Colors.white,
          height: 200, // adjust height as needed
        ),
        actions: [
          TextButton(
            onPressed: _toggleDeviceConnection,
            child: Text(
              isDeviceConnected ? "DISCONNECT" : "CONNECT",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _navigateToProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Device Overview",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 16),

            _modernInfoCard(
              title:
                  isDeviceConnected
                      ? "Device Status: ACTIVE"
                      : "Device Status: DISCONNECTED",
              icon: Icons.health_and_safety,
              iconColor: isDeviceConnected ? Colors.green : Colors.grey,
              bgColor:
                  isDeviceConnected
                      ? Colors.green.shade50
                      : Colors.grey.shade200,
            ),
            const SizedBox(height: 12),

            _modernInfoCard(
              title: "Battery Level: 75%",
              icon: Icons.battery_4_bar,
              iconColor: Colors.orangeAccent,
              bgColor: Colors.orange.shade50,
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onLongPress: _toggleWoundInfected,
              child: _modernInfoCard(
                title: "Doctor / Guardian: +386 51 999 000",
                icon: Icons.call,
                iconColor: Colors.blueAccent,
                bgColor: Colors.blue.shade50,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Nearest Hospital",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 12),

            _mapCard(),
            const SizedBox(height: 40),

            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  _mapController.move(_hospitalLocation, 15.0);
                },
                icon: const Icon(Icons.local_hospital, size: 28),
                label: const Text("Take me to the closest hospital"),
                style: ElevatedButton.styleFrom(
                  elevation: 6,
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modernInfoCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapCard() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent, width: 2),
        color: Colors.lightBlue.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(center: _hospitalLocation, zoom: 15.0),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 40,
                  height: 40,
                  point: _hospitalLocation,
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

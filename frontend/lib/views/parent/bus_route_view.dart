import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/services.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../providers/admin_provider.dart';
import '../../providers/school_provider.dart';

class BusRouteView extends StatefulWidget {
  const BusRouteView({super.key});

  @override
  State<BusRouteView> createState() => _BusRouteViewState();
}

class _BusRouteViewState extends State<BusRouteView> {
  bool _initialized = false;
  late String busId;
  late String userRole;

  IO.Socket? socket;
  double? busLat;
  double? busLng;
  double busHeading = 0.0;
  BitmapDescriptor? busIcon;
  GoogleMapController? mapController;
  final Set<Marker> _markers = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
      busId = args['busId'] ?? '';
      userRole = args['userRole'] ?? 'PARENT';

      // Connect socket if route exists
      _initSocket();

      // Load custom bus marker image asset
      _loadMarkerAsset();

      // Refresh bus routes to populate details
      Provider.of<AdminProvider>(context, listen: false).fetchBusRoutes();
      _initialized = true;
    }
  }

  bool _isIconLoading = false;

  Future<void> _loadMarkerAsset() async {
    if (_isIconLoading || busIcon != null) return;
    _isIconLoading = true;
    try {
      final icon = await BitmapDescriptor.fromAssetImage(
        createLocalImageConfiguration(context, size: const Size(30, 30)),
        'assets/images/bus_marker.png',
      );
      if (mounted) {
        setState(() {
          busIcon = icon;
        });
        debugPrint('[Marker] Custom bus marker loaded successfully.');
      }
    } catch (e) {
      debugPrint('Error loading custom bus marker asset: $e');
    } finally {
      _isIconLoading = false;
    }
  }

  void _initSocket() {
    if (busId.isEmpty) return;

    // Standardize URL structure from ApiConstants
    final socketUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    debugPrint('[Socket] Initializing client connection to: $socketUrl');

    socket = IO.io(
      socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    socket!.onConnect((_) {
      debugPrint('[Socket] Connected! Emitting join_route room event for bus: $busId');
      socket!.emit('join_route', busId);
    });

    socket!.on('location_received', (data) {
      debugPrint('[Socket] Received coordinates update package: $data');
      if (data != null && data['latitude'] != null && data['longitude'] != null) {
        final lat = (data['latitude'] as num).toDouble();
        final lng = (data['longitude'] as num).toDouble();
        final heading = data['heading'] != null ? (data['heading'] as num).toDouble() : 0.0;

        if (mounted) {
          setState(() {
            busLat = lat;
            busLng = lng;
            busHeading = heading;
          });
          _animateCamera(lat, lng);
        }
      }
    });

    socket!.onDisconnect((_) {
      debugPrint('[Socket] Disconnected from server');
    });

    socket!.onConnectError((err) {
      debugPrint('[Socket] Connection error details: $err');
    });
  }

  void _animateCamera(double lat, double lng) {
    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(lat, lng),
            zoom: 15.5,
          ),
        ),
      );
    }
  }

  void _updateMarkers(Map<String, dynamic>? route, double schoolLat, double schoolLng) {
    _markers.clear();

    // 1. Add School Marker
    _markers.add(
      Marker(
        markerId: const MarkerId('school_location'),
        position: LatLng(schoolLat, schoolLng),
        infoWindow: const InfoWindow(title: 'School Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    // 2. Determine active bus position (Real-time updates override DB coordinates)
    double? activeLat = busLat;
    double? activeLng = busLng;

    if (activeLat == null && activeLng == null && route != null && route['location'] != null) {
      activeLat = (route['location']['latitude'] as num).toDouble();
      activeLng = (route['location']['longitude'] as num).toDouble();
    }

    if (activeLat != null && activeLng != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('bus_location'),
          position: LatLng(activeLat, activeLng),
          infoWindow: InfoWindow(
            title: route != null ? route['routeName'] ?? 'Bus Route' : 'Bus Location',
            snippet: route != null ? route['busNo'] ?? 'Active' : 'Active',
          ),
          icon: busIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          flat: true,
          rotation: busHeading,
          anchor: const Offset(0.5, 0.5),
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    double? targetLat = busLat;
    double? targetLng = busLng;

    if (targetLat == null && targetLng == null) {
      final admin = Provider.of<AdminProvider>(context, listen: false);
      final route = admin.routes.firstWhere(
        (r) => r['id']?.toString() == busId,
        orElse: () => null,
      );
      if (route != null && route['location'] != null) {
        targetLat = (route['location']['latitude'] as num).toDouble();
        targetLng = (route['location']['longitude'] as num).toDouble();
      }
    }

    if (targetLat != null && targetLng != null) {
      _animateCamera(targetLat, targetLng);
    }
  }

  void _handleDialerCall(String contactNumber) {
    if (contactNumber.isEmpty) return;
    Clipboard.setData(ClipboardData(text: contactNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.copy, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Driver contact ($contactNumber) copied to clipboard!',
                style: GoogleFonts.outfit(),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green.shade700,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    if (socket != null) {
      debugPrint('[Socket] Leaving route updates room and disconnecting...');
      socket!.emit('leave_route', busId);
      socket!.disconnect();
      socket!.dispose();
    }
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (busId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Live Tracking')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No bus route context provided.',
              style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textSecondaryColor),
            ),
          ),
        ),
      );
    }

    final admin = Provider.of<AdminProvider>(context);
    final route = admin.routes.firstWhere(
      (r) => r['id']?.toString() == busId,
      orElse: () => null,
    );

    // Extract default school coordinates
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    final school = schoolProvider.currentSchool;
    final double schoolLat = school != null && school['latitude'] != null
        ? (school['latitude'] as num).toDouble()
        : 26.8467;
    final double schoolLng = school != null && school['longitude'] != null
        ? (school['longitude'] as num).toDouble()
        : 80.9462;

    _updateMarkers(route, schoolLat, schoolLng);

    // Determine initial camera position
    double initialLat = schoolLat;
    double initialLng = schoolLng;
    if (busLat != null && busLng != null) {
      initialLat = busLat!;
      initialLng = busLng!;
    } else if (route != null && route['location'] != null) {
      initialLat = (route['location']['latitude'] as num).toDouble();
      initialLng = (route['location']['longitude'] as num).toDouble();
    }

    final stops = route != null ? (route['stops'] as List<dynamic>? ?? []) : [];
    final hasRealtimeLocation = busLat != null || (route != null && route['location'] != null);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Google Maps Engine Layer
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(initialLat, initialLng),
              zoom: 14.5,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
          ),

          // 2. Floating Action Back Button Overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white.withOpacity(0.9),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // 3. Adaptive Floating M3 Custom Purple Panel UI
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF673AB7), // Brand Purple Color
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: route == null
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header Row: Vehicle details and Live status indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    route['routeName'] ?? 'Route Details',
                                    style: GoogleFonts.outfit(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    route['busNo'] ?? '',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (hasRealtimeLocation)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade600,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.circle, size: 8, color: Colors.white),
                                    const SizedBox(width: 6),
                                    Text(
                                      'LIVE',
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const Divider(color: Colors.white24, height: 24),

                        // Dialer link & Driver details
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white24,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    route['driverName'] ?? 'Driver',
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    route['driverContact'] ?? '',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF673AB7),
                              ),
                              icon: const Icon(Icons.phone),
                              onPressed: () => _handleDialerCall(route['driverContact'] ?? ''),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Adaptive Section: PARENT vs HM/CORRESPONDENT UI Layout
                        if (userRole == 'PARENT') ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.directions_bus_filled, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    hasRealtimeLocation
                                        ? 'Bus is currently active and on its way.'
                                        : 'Waiting for driver to start location sharing...',
                                    style: GoogleFonts.outfit(fontSize: 13, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // HM or CORRESPONDENT Management statistics
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Route Manager Details',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  '${route['students']?.length ?? 0} Students Assigned',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Expandable / Scrollable Stops Sequence block to prevent overflows
                        if (stops.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Route Stops Sequence',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height * 0.16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              itemCount: stops.length,
                              itemBuilder: (context, idx) {
                                final stop = stops[idx];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 14, color: Colors.white70),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${stop['sequenceNo']}. ${stop['stopName']}',
                                          style: GoogleFonts.outfit(fontSize: 12, color: Colors.white),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        stop['arrivalTime'] ?? '',
                                        style: GoogleFonts.outfit(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

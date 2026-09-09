import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class MapPickerScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const MapPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  bool _isLoadingCurrentLocation = false;

  // Default coordinate (e.g. Bangalore/India default if no location is selected yet)
  static const LatLng _defaultLocation = LatLng(12.971598, 77.594562);

  @override
  void initState() {
    super.initState();
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedLocation = LatLng(widget.initialLatitude!, widget.initialLongitude!);
    } else {
      _selectedLocation = _defaultLocation;
      _goToCurrentLocation(initialLoad: true);
    }
  }

  Future<void> _goToCurrentLocation({bool initialLoad = false}) async {
    setState(() {
      _isLoadingCurrentLocation = true;
    });

    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!initialLoad) {
            _showSnackBar('Location permission denied.', Colors.redAccent);
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!initialLoad) {
          _showSnackBar('Location permissions are permanently denied. Please enable them in settings.', Colors.redAccent);
        }
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final LatLng currentLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _selectedLocation = currentLatLng;
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: currentLatLng, zoom: 16.0),
          ),
        );
      }
    } catch (e) {
      if (!initialLoad) {
        _showSnackBar('Error fetching current location: $e', Colors.redAccent);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCurrentLocation = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.outfit()),
        backgroundColor: bgColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Set<Marker> markers = _selectedLocation == null
        ? {}
        : {
            Marker(
              markerId: const MarkerId('selected-location'),
              position: _selectedLocation!,
              draggable: true,
              onDragEnd: (LatLng newPos) {
                setState(() {
                  _selectedLocation = newPos;
                });
              },
            ),
          };

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Select Location',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white.withOpacity(0.9),
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shadowColor: Colors.black12,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Stack(
        children: [
          // Google Map representation
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation ?? _defaultLocation,
              zoom: 15.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              if (_selectedLocation != null) {
                _mapController!.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: _selectedLocation!, zoom: 15.0),
                  ),
                );
              }
            },
            onTap: (LatLng latLng) {
              setState(() {
                _selectedLocation = latLng;
              });
            },
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // Custom floating button
            zoomControlsEnabled: false,
          ),

          if (_isLoadingCurrentLocation)
            const Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Locating you...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Bottom Action Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected Coordinates',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _selectedLocation != null
                                  ? '${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}'
                                  : 'Tap on the map to select',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _selectedLocation == null
                        ? null
                        : () {
                            Navigator.pop(context, _selectedLocation);
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Confirm Location',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Action Button for "Current Location"
          Positioned(
            bottom: 156, // Sits right above the bottom panel
            right: 16,
            child: FloatingActionButton(
              heroTag: 'my-location-fab',
              onPressed: () => _goToCurrentLocation(),
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}

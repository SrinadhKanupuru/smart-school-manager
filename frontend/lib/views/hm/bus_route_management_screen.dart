import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/admin_provider.dart';
import '../../providers/school_provider.dart';
import '../../core/theme.dart';

class BusRouteManagementScreen extends StatefulWidget {
  const BusRouteManagementScreen({super.key});

  @override
  State<BusRouteManagementScreen> createState() => _BusRouteManagementScreenState();
}

class _BusRouteManagementScreenState extends State<BusRouteManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchBusRoutes();
    });
  }



  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Bus Routes')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: admin.routes.isEmpty
                  ? Center(child: Text('No bus routes configured.', style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: admin.routes.length,
                      itemBuilder: (context, index) {
                        final route = admin.routes[index];
                        final stops = route['stops'] as List<dynamic>? ?? [];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 1,
                          child: InkWell(
                            onTap: () {
                              final busId = route['id']?.toString() ?? '';
                              final userRole = Provider.of<SchoolProvider>(context, listen: false).currentUser?['role'] ?? 'HM';
                              Navigator.pushNamed(
                                context,
                                '/bus-route-view',
                                arguments: {
                                  'busId': busId,
                                  'userRole': userRole,
                                },
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        route['routeName'] ?? '',
                                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                                      ),
                                      Text(
                                        route['busNo'] ?? '',
                                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Driver: ${route['driverName']} • ${route['driverContact']}',
                                    style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor, fontSize: 13),
                                  ),
                                  const Divider(height: 24),
                                  Text(
                                    'Stops Sequence:',
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  ...stops.map((stop) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.location_on, size: 16, color: AppTheme.primaryColor),
                                          const SizedBox(width: 8),
                                          Text('${stop['sequenceNo']}. ${stop['stopName']}', style: GoogleFonts.outfit(fontSize: 13)),
                                          const Spacer(),
                                          Text(stop['arrivalTime'] ?? '', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                                        ],
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 8),
                                  if (route['students'] != null && (route['students'] as List).isNotEmpty) ...[
                                    const Divider(height: 24),
                                    Text(
                                      'Assigned Children:',
                                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: (route['students'] as List).map((std) {
                                        return Chip(
                                          label: Text(
                                            std['fullName'] ?? '',
                                            style: GoogleFonts.outfit(fontSize: 12),
                                          ),
                                          backgroundColor: AppTheme.primaryColor.withOpacity(0.06),
                                          side: BorderSide.none,
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/add-bus-route').then((_) {
                    admin.fetchBusRoutes();
                  });
                },
                child: const Text('Add Bus Route'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/ble_service.dart';
import 'services/recognition_service.dart';
import 'services/geofence_service.dart';
import 'services/notification_service.dart';
import 'models/people_store.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  await PeopleStore().load();
  runApp(const AuraApp());
}

class AuraApp extends StatelessWidget {
  const AuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BleService()),
        ChangeNotifierProvider(create: (_) => RecognitionService()),
        ChangeNotifierProvider(create: (_) => GeofenceService()),
      ],
      child: MaterialApp(
        title: 'Memory Helper',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF3F51B5),
          ),
          textTheme: const TextTheme(
            displayLarge:
                TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            bodyLarge:  TextStyle(fontSize: 24),
            bodyMedium: TextStyle(fontSize: 20),
            labelLarge:
                TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 72),
              textStyle: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        home: const _AppRoot(),
      ),
    );
  }
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();
  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  @override
  void initState() {
    super.initState();

    // Wire up callbacks immediately (no delay needed here)
    final ble = context.read<BleService>();
    final rec = context.read<RecognitionService>();
    final geo = context.read<GeofenceService>();

    ble.onNfcTag    = (uid) => rec.handleTag(uid);
    ble.onGpsUpdate = (lat, lng) => geo.updatePosition(lat, lng);

    // Delay BLE start by 1 second:
    // iOS CoreBluetooth stack is not ready immediately after app launch.
    // Without this delay, adapterState can return 'unknown' even when
    // Bluetooth is physically ON, causing a false "BT is off" error.
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        ble.startScan();
        geo.startMonitoring();
      }
    });
  }

  @override
  Widget build(BuildContext context) => const HomeScreen();
}
// // lib/main.dart
// // "Titania" - Complex Demo App for learning advanced Flutter & Dart concepts.
// // Save as lib/main.dart and run with `flutter run`.
// //
// // Features included (quick list):
// // - App architecture with RouteGenerator, DI via InheritedWidget, ServiceLayer
// // - Custom state management (AppStore) using ChangeNotifier & Streams
// // - Localization (simple map-based), Theme switching (light/dark/custom)
// // - Advanced OOP: Factory, Mixins, Generics, Extension methods
// // - Async operations: Futures, async/await, simulated HTTP, background Isolate
// // - Streams + WebSocket simulation via StreamController
// // - Dynamic JSON parsing using `dynamic` and typed models
// // - Complex UI: animations, CustomPainter, nested widgets, forms & validation
// // - Error handling, logging (simple), caching simulation
// // - Example of compute heavy task using Isolate
// //
// // This file is intentionally long and dense to demonstrate many patterns.
// // Read comments for explanation.

// import 'dart:async';
// import 'dart:convert';
// import 'dart:isolate';
// import 'dart:math';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

// // ----------------------------- Utilities -----------------------------------

// /// Simple logger util
// class L {
//   static void i(String msg) => debugPrint('[INFO] $msg');
//   static void w(String msg) => debugPrint('[WARN] $msg');
//   static void e(String msg) => debugPrint('[ERROR] $msg');
// }

// /// Extension on String
// extension StringExt on String {
//   String capitalize() =>
//       isEmpty ? this : this[0].toUpperCase() + substring(1).toLowerCase();
// }

// // ----------------------------- Localization --------------------------------

// class LocaleStrings {
//   final String locale;
//   LocaleStrings(this.locale);

//   static const Map<String, Map<String, String>> _map = {
//     'en': {
//       'title': 'Titania — Advanced Demo',
//       'home': 'Home',
//       'dashboard': 'Dashboard',
//       'settings': 'Settings',
//       'profile': 'Profile',
//       'load_data': 'Load Data',
//       'simulate_ws': 'Simulate WebSocket',
//       'heavy_task': 'Run Heavy Task',
//       'theme': 'Theme',
//       'language': 'Language',
//       'logout': 'Logout',
//       'name': 'Name',
//       'email': 'Email',
//       'submit': 'Submit',
//     },
//     'id': {
//       'title': 'Titania — Demo Lanjutan',
//       'home': 'Beranda',
//       'dashboard': 'Dasbor',
//       'settings': 'Pengaturan',
//       'profile': 'Profil',
//       'load_data': 'Muat Data',
//       'simulate_ws': 'Simulasi WebSocket',
//       'heavy_task': 'Jalankan Tugas Berat',
//       'theme': 'Tema',
//       'language': 'Bahasa',
//       'logout': 'Keluar',
//       'name': 'Nama',
//       'email': 'Surel',
//       'submit': 'Kirim',
//     }
//   };

//   String t(String key) {
//     return _map[locale]?[key] ?? _map['en']![key] ?? key;
//   }

//   static List<String> supported = ['en', 'id'];
// }

// // ----------------------------- Models --------------------------------------

// /// Generic API Response
// class ApiResponse<T> {
//   final bool success;
//   final String message;
//   final T? payload;

//   ApiResponse({required this.success, required this.message, this.payload});

//   @override
//   String toString() =>
//       'ApiResponse(success:$success, message:$message, payload:$payload)';
// }

// /// Example typed model with factory created from dynamic (JSON)
// class UserProfile {
//   final String id;
//   final String name;
//   final String email;
//   final DateTime createdAt;

//   UserProfile({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.createdAt,
//   });

//   factory UserProfile.fromDynamic(dynamic d) {
//     // robust parsing with dynamic safety checks
//     if (d is Map) {
//       final id = (d['id'] ?? 'u_${Random().nextInt(10000)}').toString();
//       final name = (d['name'] ?? 'Anonymous').toString();
//       final email = (d['email'] ?? 'no-reply@example.com').toString();
//       final createdAt = DateTime.tryParse(d['createdAt']?.toString() ?? '') ??
//           DateTime.now();
//       return UserProfile(
//         id: id,
//         name: name,
//         email: email,
//         createdAt: createdAt,
//       );
//     } else {
//       throw FormatException('Invalid dynamic for UserProfile');
//     }
//   }

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'name': name,
//         'email': email,
//         'createdAt': createdAt.toIso8601String(),
//       };

//   @override
//   String toString() => 'UserProfile($id, $name, $email)';
// }

// // ----------------------------- Services ------------------------------------

// // Simulated HTTP Service (no external dependency)
// class FakeHttpService {
//   // Simulate GET returning dynamic JSON
//   Future<dynamic> get(String path) async {
//     L.i('HTTP GET $path');
//     await Future.delayed(Duration(milliseconds: 800 + Random().nextInt(1200)));
//     // produce dynamic response
//     if (path.contains('user')) {
//       return {
//         'id': 'u1234',
//         'name': 'Naufal Mirza',
//         'email': 'naufal@example.com',
//         'createdAt': DateTime.now().toIso8601String(),
//       };
//     } else if (path.contains('items')) {
//       return List.generate(6, (i) {
//         return {
//           'id': 'it$i',
//           'title': 'Item #$i',
//           'value': Random().nextInt(1000),
//         };
//       });
//     } else {
//       return {'status': 'ok', 'time': DateTime.now().toIso8601String()};
//     }
//   }

//   // Simulate POST
//   Future<dynamic> post(String path, dynamic body) async {
//     L.i('HTTP POST $path with body ${jsonEncode(body)}');
//     await Future.delayed(Duration(milliseconds: 600));
//     return {'status': 'created', 'body': body, 'time': DateTime.now().toIso8601String()};
//   }
// }

// // WebSocket simulation using StreamController
// class FakeWebSocketService {
//   final StreamController<String> _controller = StreamController.broadcast();
//   Timer? _ticker;

//   Stream<String> get stream => _controller.stream;

//   void start() {
//     _ticker = Timer.periodic(Duration(seconds: 2), (t) {
//       final payload = jsonEncode({
//         'evt': 'tick',
//         'val': Random().nextInt(1000),
//         'at': DateTime.now().toIso8601String()
//       });
//       _controller.add(payload);
//     });
//     L.i('FakeWebSocket started');
//   }

//   void stop() {
//     _ticker?.cancel();
//     _ticker = null;
//     L.i('FakeWebSocket stopped');
//   }

//   void send(String msg) {
//     L.i('FakeWebSocket send: $msg');
//     // echo back after short delay
//     Future.delayed(Duration(milliseconds: 300), () {
//       _controller.add(jsonEncode({'evt': 'echo', 'msg': msg, 'at': DateTime.now().toIso8601String()}));
//     });
//   }

//   void dispose() {
//     stop();
//     _controller.close();
//   }
// }

// // Heavy computation using isolate
// Future<int> heavyComputationInIsolate(int n) async {
//   // send n to isolate and get sum of primes up to n (example heavy)
//   final p = ReceivePort();
//   await Isolate.spawn(_heavyIsolateEntry, [p.sendPort, n]);
//   return await p.first as int;
// }

// void _heavyIsolateEntry(List<dynamic> args) {
//   SendPort send = args[0];
//   int n = args[1] as int;
//   int sum = 0;
//   for (int i = 2; i <= n; i++) {
//     if (_isPrime(i)) sum += i;
//   }
//   send.send(sum);
// }

// bool _isPrime(int x) {
//   if (x < 2) return false;
//   for (int i = 2; i * i <= x; i++) {
//     if (x % i == 0) return false;
//   }
//   return true;
// }

// // ----------------------------- App Store (State) ---------------------------

// class AppStore extends ChangeNotifier {
//   // Dependencies
//   final FakeHttpService http;
//   final FakeWebSocketService ws;

//   // State
//   LocaleStrings _locale = LocaleStrings('en');
//   ThemeMode _themeMode = ThemeMode.system;
//   UserProfile? _profile;
//   bool _loading = false;

//   // Stream for real-time messages
//   final StreamController<String> _realtime = StreamController.broadcast();

//   AppStore({required this.http, required this.ws}) {
//     ws.stream.listen((raw) {
//       _realtime.add(raw);
//       L.i('AppStore relayed WS message');
//     });
//   }

//   // Getters
//   LocaleStrings get locale => _locale;
//   ThemeMode get themeMode => _themeMode;
//   UserProfile? get profile => _profile;
//   bool get loading => _loading;
//   Stream<String> get realtime => _realtime.stream;

//   // Actions
//   Future<void> loadProfile() async {
//     _setLoading(true);
//     try {
//       final raw = await http.get('/user/profile');
//       _profile = UserProfile.fromDynamic(raw);
//       L.i('Profile loaded: $_profile');
//     } catch (e) {
//       L.e('Error loadProfile: $e');
//     }
//     _setLoading(false);
//     notifyListeners();
//   }

//   Future<ApiResponse<List<Map<String, dynamic>>>> loadItems() async {
//     _setLoading(true);
//     try {
//       final raw = await http.get('/items');
//       if (raw is List) {
//         final list = raw.map((e) => Map<String, dynamic>.from(e)).toList();
//         _setLoading(false);
//         return ApiResponse(success: true, message: 'OK', payload: list);
//       } else {
//         _setLoading(false);
//         return ApiResponse(success: false, message: 'Invalid data', payload: null);
//       }
//     } catch (e) {
//       _setLoading(false);
//       return ApiResponse(success: false, message: e.toString(), payload: null);
//     }
//   }

//   void setLocale(String code) {
//     if (!LocaleStrings.supported.contains(code)) return;
//     _locale = LocaleStrings(code);
//     notifyListeners();
//   }

//   void setTheme(ThemeMode mode) {
//     _themeMode = mode;
//     notifyListeners();
//   }

//   void sendWs(String msg) => ws.send(msg);

//   Future<int> runHeavyTask(int n) async {
//     _setLoading(true);
//     final result = await heavyComputationInIsolate(n);
//     _setLoading(false);
//     return result;
//   }

//   void _setLoading(bool v) {
//     _loading = v;
//     notifyListeners();
//   }

//   void disposeStore() {
//     _realtime.close();
//     ws.dispose();
//   }
// }

// // InheritedWidget for DI (simple)
// class AppDI extends InheritedWidget {
//   final AppStore store;

//   AppDI({Key? key, required Widget child, required this.store})
//       : super(key: key, child: child);

//   static AppDI of(BuildContext context) {
//     final AppDI? result = context.dependOnInheritedWidgetOfExactType<AppDI>();
//     assert(result != null, 'No AppDI found in context');
//     return result!;
//   }

//   @override
//   bool updateShouldNotify(AppDI oldWidget) => store != oldWidget.store;
// }

// // ----------------------------- UI Widgets ----------------------------------

// // Route generator
// class RouteGenerator {
//   static Route<dynamic> generate(RouteSettings settings) {
//     final args = settings.arguments;
//     switch (settings.name) {
//       case '/':
//         return MaterialPageRoute(builder: (_) => HomePage());
//       case '/dashboard':
//         return MaterialPageRoute(builder: (_) => DashboardPage());
//       case '/settings':
//         return MaterialPageRoute(builder: (_) => SettingsPage());
//       case '/profile':
//         return MaterialPageRoute(builder: (_) => ProfilePage());
//       default:
//         return MaterialPageRoute(
//             builder: (_) => Scaffold(
//                   appBar: AppBar(title: Text('404')),
//                   body: Center(child: Text('Route ${settings.name} not found')),
//                 ));
//     }
//   }
// }

// // App Root
// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   final http = FakeHttpService();
//   final ws = FakeWebSocketService();
//   final store = AppStore(http: http, ws: ws);
//   ws.start();
//   runApp(AppDI(
//     store: store,
//     child: MyApp(),
//   ));
// }

// class MyApp extends StatefulWidget {
//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   late AppStore store;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     store = AppDI.of(context).store;
//     store.addListener(_onStore);
//   }

//   @override
//   void dispose() {
//     store.removeListener(_onStore);
//     super.dispose();
//   }

//   void _onStore() => setState(() {});

//   @override
//   Widget build(BuildContext context) {
//     final loc = store.locale;
//     return MaterialApp(
//       title: loc.t('title'),
//       themeMode: store.themeMode,
//       theme: ThemeData.light().copyWith(
//         primaryColor: Colors.indigo,
//         colorScheme: ColorScheme.light(primary: Colors.indigo),
//       ),
//       darkTheme: ThemeData.dark().copyWith(
//         primaryColor: Colors.teal,
//         colorScheme: ColorScheme.dark(primary: Colors.teal),
//       ),
//       initialRoute: '/',
//       onGenerateRoute: RouteGenerator.generate,
//     );
//   }
// }

// // Home Page (complex UI)
// class HomePage extends StatefulWidget {
//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
//   late AppStore store;
//   late AnimationController _logoController;
//   late Animation<double> _logoScale;
//   final _formKey = GlobalKey<FormState>();
//   String _inputName = '';
//   String _inputEmail = '';

//   @override
//   void initState() {
//     super.initState();
//     _logoController =
//         AnimationController(vsync: this, duration: Duration(seconds: 3));
//     _logoScale = Tween<double>(begin: 0.7, end: 1.1).animate(CurvedAnimation(
//         parent: _logoController, curve: Curves.elasticOut));
//     _logoController.repeat(reverse: true);
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     store = AppDI.of(context).store;
//   }

//   @override
//   void dispose() {
//     _logoController.dispose();
//     super.dispose();
//   }

//   Future<void> _submitForm() async {
//     if (!_formKey.currentState!.validate()) return;
//     _formKey.currentState!.save();
//     // Simulate submitting
//     final body = {'name': _inputName, 'email': _inputEmail};
//     final res = await store.http.post('/profile/update', body);
//     L.i('Submit result: $res');
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Submitted: ${jsonEncode(body)}')),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final loc = store.locale;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(loc.t('home')),
//         actions: [
//           IconButton(
//             tooltip: loc.t('dashboard'),
//             icon: Icon(Icons.dashboard),
//             onPressed: () => Navigator.of(context).pushNamed('/dashboard'),
//           ),
//           IconButton(
//             tooltip: loc.t('settings'),
//             icon: Icon(Icons.settings),
//             onPressed: () => Navigator.of(context).pushNamed('/settings'),
//           )
//         ],
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(12),
//           child: Column(
//             children: [
//               // Animated Logo + CustomPainter
//               ScaleTransition(
//                 scale: _logoScale,
//                 child: SizedBox(
//                   height: 160,
//                   child: CustomPaint(
//                     painter: ConcentricCirclesPainter(),
//                     child: Center(
//                         child: Text('Titania',
//                             style: TextStyle(
//                                 fontSize: 28, fontWeight: FontWeight.bold))),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 12),
//               // Loading / Profile summary
//               Card(
//                 child: ListTile(
//                   leading: Icon(Icons.person),
//                   title: Text(store.profile?.name ?? 'Anonymous'),
//                   subtitle: Text(store.profile?.email ?? 'No email'),
//                   trailing: store.loading
//                       ? SizedBox(
//                           width: 24,
//                           height: 24,
//                           child: CircularProgressIndicator(strokeWidth: 2))
//                       : IconButton(
//                           icon: Icon(Icons.refresh),
//                           onPressed: () => store.loadProfile(),
//                         ),
//                 ),
//               ),
//               SizedBox(height: 12),
//               // Real-time stream display (WebSocket)
//               RealtimePanel(),
//               SizedBox(height: 12),
//               // Form Demo
//               Card(
//                 child: Padding(
//                   padding: EdgeInsets.all(12),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         Text('Quick Profile Form', style: TextStyle(fontSize: 16)),
//                         SizedBox(height: 8),
//                         TextFormField(
//                           decoration: InputDecoration(labelText: loc.t('name')),
//                           validator: (v) {
//                             if (v == null || v.trim().length < 3) {
//                               return 'Name must be at least 3 chars';
//                             }
//                             return null;
//                           },
//                           onSaved: (v) => _inputName = v!.trim(),
//                         ),
//                         SizedBox(height: 8),
//                         TextFormField(
//                           decoration: InputDecoration(labelText: loc.t('email')),
//                           validator: (v) {
//                             if (v == null ||
//                                 !v.contains('@') ||
//                                 !v.contains('.')) return 'Invalid email';
//                             return null;
//                           },
//                           onSaved: (v) => _inputEmail = v!.trim(),
//                         ),
//                         SizedBox(height: 12),
//                         ElevatedButton(
//                           onPressed: _submitForm,
//                           child: Text(loc.t('submit')),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 12),
//               // Complex Grid + Animated Tiles
//               AnimatedTilesGrid(),
//               SizedBox(height: 24),
//               // Heavy task button
//               ElevatedButton.icon(
//                 icon: Icon(Icons.memory),
//                 label: Text(loc.t('heavy_task')),
//                 onPressed: () async {
//                   final n = 40000; // heavy
//                   final snack = ScaffoldMessenger.of(context);
//                   snack.showSnackBar(SnackBar(content: Text('Running heavy task...')));
//                   final result = await store.runHeavyTask(n);
//                   snack.showSnackBar(SnackBar(content: Text('Result sum primes up to $n: $result')));
//                 },
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // CustomPainter example
// class ConcentricCirclesPainter extends CustomPainter {
//   final Random _rnd = Random();
//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final maxR = min(size.width, size.height) / 2;
//     for (int i = 4; i >= 1; i--) {
//       final paint = Paint()
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 6.0 / i
//         ..color = Colors.primaries[i * 3 % Colors.primaries.length].withOpacity(0.2 + i * 0.15);
//       canvas.drawCircle(center, maxR * i / 4, paint);
//     }
//     // draw random star
//     final p = Paint()..color = Colors.amber.withOpacity(0.8);
//     final path = Path();
//     path.moveTo(center.dx, center.dy - maxR * 0.35);
//     for (int i = 1; i <= 5; i++) {
//       double angle = i * 2 * pi / 5 - pi / 2;
//       path.lineTo(center.dx + cos(angle) * (maxR * 0.12 + _rnd.nextDouble() * 6),
//           center.dy + sin(angle) * (maxR * 0.12 + _rnd.nextDouble() * 6));
//     }
//     path.close();
//     canvas.drawPath(path, p);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// // RealtimePanel widget: listens to AppStore.realtime stream
// class RealtimePanel extends StatefulWidget {
//   @override
//   State<RealtimePanel> createState() => _RealtimePanelState();
// }

// class _RealtimePanelState extends State<RealtimePanel> {
//   late AppStore store;
//   final List<String> _messages = [];

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     store = AppDI.of(context).store;
//     store.realtime.listen((raw) {
//       setState(() {
//         _messages.insert(0, raw);
//         if (_messages.length > 10) _messages.removeLast();
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: ExpansionTile(
//         leading: Icon(Icons.wifi_tethering),
//         title: Text('Realtime Feed'),
//         children: [
//           SizedBox(
//             height: 140,
//             child: ListView.builder(
//               reverse: true,
//               itemCount: _messages.length,
//               itemBuilder: (ctx, i) {
//                 final m = _messages[i];
//                 final parsed = jsonDecode(m);
//                 return ListTile(
//                   dense: true,
//                   title: Text(parsed['evt'] ?? 'evt'),
//                   subtitle: Text(m),
//                   trailing: IconButton(
//                     icon: Icon(Icons.send),
//                     onPressed: () => store.sendWs('Client ack ${DateTime.now().toIso8601String()}'),
//                   ),
//                 );
//               },
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

// // Animated grid of tiles (complex UI + animations)
// class AnimatedTilesGrid extends StatefulWidget {
//   @override
//   State<AnimatedTilesGrid> createState() => _AnimatedTilesGridState();
// }

// class _AnimatedTilesGridState extends State<AnimatedTilesGrid> with TickerProviderStateMixin {
//   late AnimationController _controller;
//   List<Animation<double>> _anims = [];

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(vsync: this, duration: Duration(seconds: 4));
//     _anims = List.generate(6, (i) {
//       final start = i * 0.08;
//       final end = start + 0.6;
//       return CurvedAnimation(parent: _controller, curve: Interval(start, end, curve: Curves.elasticOut));
//     });
//     _controller.repeat(reverse: true);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GridView.count(
//       physics: NeverScrollableScrollPhysics(),
//       shrinkWrap: true,
//       crossAxisCount: 3,
//       crossAxisSpacing: 6,
//       mainAxisSpacing: 6,
//       children: List.generate(6, (i) => _buildTile(i)),
//     );
//   }

//   Widget _buildTile(int i) {
//     return ScaleTransition(
//       scale: _anims[i],
//       child: GestureDetector(
//         onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tile $i tapped'))),
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(colors: [Colors.primaries[i % Colors.primaries.length], Colors.white]),
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))]
//           ),
//           child: Center(child: Text('TILE ${i+1}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
//         ),
//       ),
//     );
//   }
// }

// // Dashboard Page: demonstrates dynamic JSON parsing and list rendering
// class DashboardPage extends StatefulWidget {
//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }

// class _DashboardPageState extends State<DashboardPage> {
//   late AppStore store;
//   List<Map<String, dynamic>> _items = [];
//   bool _loading = false;

//   Future<void> _load() async {
//     setState(() => _loading = true);
//     final res = await AppDI.of(context).store.loadItems();
//     if (res.success && res.payload != null) {
//       setState(() {
//         _items = res.payload!;
//       });
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load items: ${res.message}')));
//     }
//     setState(() => _loading = false);
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     store = AppDI.of(context).store;
//     // preload
//     _load();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final loc = store.locale;
//     return Scaffold(
//       appBar: AppBar(title: Text(loc.t('dashboard'))),
//       body: Column(
//         children: [
//           ListTile(
//             title: Text('Dynamic JSON Items'),
//             trailing: _loading ? CircularProgressIndicator() : IconButton(icon: Icon(Icons.refresh), onPressed: _load),
//           ),
//           Expanded(
//             child: _items.isEmpty
//                 ? Center(child: Text('No items'))
//                 : ListView.builder(
//                     itemCount: _items.length,
//                     itemBuilder: (ctx, i) {
//                       final item = _items[i];
//                       // dynamic typing safety: use Map check
//                       final id = item['id']?.toString() ?? 'no-id';
//                       final title = item['title']?.toString() ?? 'untitled';
//                       final val = item['value']?.toString() ?? '0';
//                       return Card(
//                         child: ListTile(
//                           title: Text(title),
//                           subtitle: Text('Value: $val'),
//                           trailing: IconButton(
//                             icon: Icon(Icons.info_outline),
//                             onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(
//                               title: Text('Item $id'),
//                               content: Text(jsonEncode(item)),
//                             )),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Settings Page: theme & language toggles
// class SettingsPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final store = AppDI.of(context).store;
//     final loc = store.locale;
//     return Scaffold(
//       appBar: AppBar(title: Text(loc.t('settings'))),
//       body: Padding(
//         padding: EdgeInsets.all(12),
//         child: Column(
//           children: [
//             ListTile(
//               title: Text(loc.t('theme')),
//               trailing: DropdownButton<ThemeMode>(
//                 value: store.themeMode,
//                 items: [
//                   DropdownMenuItem(child: Text('System'), value: ThemeMode.system),
//                   DropdownMenuItem(child: Text('Light'), value: ThemeMode.light),
//                   DropdownMenuItem(child: Text('Dark'), value: ThemeMode.dark),
//                 ],
//                 onChanged: (v) {
//                   if (v != null) store.setTheme(v);
//                 },
//               ),
//             ),
//             ListTile(
//               title: Text(loc.t('language')),
//               trailing: DropdownButton<String>(
//                 value: store.locale.locale,
//                 items: LocaleStrings.supported.map((c) => DropdownMenuItem(child: Text(c.toUpperCase()), value: c)).toList(),
//                 onChanged: (v) {
//                   if (v != null) store.setLocale(v);
//                 },
//               ),
//             ),
//             Divider(),
//             ListTile(
//               title: Text('Simulate WebSocket'),
//               subtitle: Text('Open a panel to view realtime messages'),
//               trailing: IconButton(
//                 icon: Icon(Icons.wifi),
//                 onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RealtimePanelPage())),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Realtime full page
// class RealtimePanelPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final store = AppDI.of(context).store;
//     return Scaffold(
//       appBar: AppBar(title: Text('Realtime Messages')),
//       body: StreamBuilder<String>(
//         stream: store.realtime,
//         builder: (ctx, snap) {
//           final list = <Widget>[];
//           if (snap.hasData) {
//             final str = snap.data!;
//             list.add(ListTile(title: Text('Event'), subtitle: Text(str)));
//           }
//           return Column(
//             children: [
//               Expanded(child: ListView.builder(itemCount: 20, itemBuilder: (_, i) => ListTile(title: Text('History placeholder #$i')))),
//               Padding(
//                 padding: EdgeInsets.all(12),
//                 child: Row(
//                   children: [
//                     Expanded(child: TextField(decoration: InputDecoration(hintText: 'Send message to WS'))),
//                     IconButton(icon: Icon(Icons.send), onPressed: () => store.sendWs('Hello ${DateTime.now().toIso8601String()}')),
//                   ],
//                 ),
//               )
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// // Profile Page simple show typed model
// class ProfilePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final store = AppDI.of(context).store;
//     final loc = store.locale;
//     final profile = store.profile;
//     return Scaffold(
//       appBar: AppBar(title: Text(loc.t('profile'))),
//       body: profile == null
//           ? Center(child: Text('No profile loaded. Please refresh on Home.'))
//           : Padding(
//               padding: EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('ID: ${profile.id}'),
//                   SizedBox(height: 8),
//                   Text('${loc.t('name')}: ${profile.name}'),
//                   SizedBox(height: 8),
//                   Text('${loc.t('email')}: ${profile.email}'),
//                   SizedBox(height: 8),
//                   Text('Created: ${profile.createdAt}'),
//                 ],
//               ),
//             ),
//     );
//   }
// }

// // ----------------------------- END FILE ------------------------------------
import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text("Halo Flutter, berhasil jalan!"),
        ),
      ),
    ),
  );
}

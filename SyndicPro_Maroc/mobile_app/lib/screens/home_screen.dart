import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? data;
  String? error;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await ApiService.dashboard();
      if (mounted)
        setState(() {
          data = result;
          loading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          error = e.toString();
          loading = false;
        });
    }
  }

  String money(dynamic value) =>
      '${(value as num? ?? 0).toStringAsFixed(2)} DH';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SyndicPro Maroc',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              Text('تدبير العمارة بكل شفافية',
                  style: TextStyle(fontSize: 12, color: Colors.black54)),
            ]),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh))
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF176B56), Color(0xFF319879)]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('مرحباً بك 👋', style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 8),
                  Text('كل ما يخص عمارتك في مكان واحد.',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('المحاسبة • الصيانة • التواصل',
                      style: TextStyle(color: Colors.white70)),
                ]),
          ),
          const SizedBox(height: 18),
          if (loading)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator())),
          if (error != null)
            Card(
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      Text('تعذر الاتصال بالخادم\n$error',
                          textAlign: TextAlign.center),
                      TextButton(
                          onPressed: _load,
                          child: const Text('إعادة المحاولة')),
                    ]))),
          if (data != null)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.45,
              children: [
                _stat('المداخيل', money(data!['total_income']),
                    Icons.south_west, Colors.green),
                _stat('المصاريف', money(data!['total_expenses']),
                    Icons.north_east, Colors.orange),
                _stat('الرصيد', money(data!['balance']),
                    Icons.account_balance_wallet, Colors.teal),
                _stat('الشقق', '${data!['apartments_count']}', Icons.apartment,
                    Colors.blue),
              ],
            ),
          const SizedBox(height: 18),
          const Text('الخدمات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _action(context, 'العمارات', 'إدارة الإقامات والعمارات',
              Icons.location_city, '/buildings'),
          _action(context, 'الشقق', 'الملاك ومعلومات الشقق',
              Icons.door_front_door, '/apartments'),
          _action(context, 'الأداءات', 'تسجيل واجبات السانديك', Icons.payments,
              '/payments'),
          _action(context, 'المصاريف', 'الفواتير ومصاريف العمارة',
              Icons.receipt_long, '/expenses'),
          _action(context, 'الشكايات', 'تتبع المشاكل والإصلاحات',
              Icons.handyman, '/complaints'),
          const SizedBox(height: 10),
          Text('الشكايات المفتوحة: ${data?['open_complaints'] ?? '—'}',
              style: const TextStyle(color: Colors.black54),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _stat(String title, String value, IconData icon, Color color) => Card(
        child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color),
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 17)),
                Text(title, style: const TextStyle(color: Colors.black54)),
              ],
            )),
      );

  Widget _action(BuildContext context, String title, String subtitle,
          IconData icon, String type) =>
      Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
              backgroundColor: const Color(0xFFE7F2EE),
              child: Icon(icon, color: const Color(0xFF247A62))),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ListScreen(type: type, title: title)))
                .then((_) => _load());
          },
        ),
      );
}

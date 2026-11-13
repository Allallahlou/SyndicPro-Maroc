import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'create_screen.dart';

class ListScreen extends StatefulWidget {
  final String type;
  final String title;
  const ListScreen({super.key, required this.type, required this.title});
  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late Future<List<dynamic>> future;
  String get endpoint => widget.type;
  @override
  void initState() { super.initState(); future = ApiService.getList(endpoint); }
  void reload() => setState(() { future = ApiService.getList(endpoint); });

  String subtitle(Map<String,dynamic> item) {
    switch (widget.type) {
      case '/buildings': return '${item['city'] ?? ''} • ${item['address'] ?? ''}\nواجب السانديك: ${item['monthly_fee'] ?? 0} DH';
      case '/apartments': return 'المالك: ${item['owner_name'] ?? 'غير محدد'} • الطابق: ${item['floor'] ?? 0}\nالعمارة رقم: ${item['building_id']}';
      case '/payments': return '${item['amount']} DH • الشقة: ${item['apartment_id']} • ${item['paid_on']}';
      case '/expenses': return '${item['amount']} DH • ${item['category'] ?? ''} • ${item['spent_on']}';
      default: return '${item['category'] ?? ''} • ${_status(item['status'])}\n${item['description'] ?? ''}';
    }
  }
  String _status(dynamic value) => switch(value) {'new' => 'جديدة', 'in_progress' => 'قيد المعالجة', 'resolved' => 'تم الحل', 'rejected' => 'مرفوضة', _ => '$value'};
  IconData get icon => switch(widget.type) {'/buildings' => Icons.apartment, '/apartments' => Icons.door_front_door, '/payments' => Icons.payments, '/expenses' => Icons.receipt_long, _ => Icons.handyman};

  Future<void> add() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => CreateScreen(type: widget.type, title: widget.title)));
    if (result == true) reload();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title), actions: [IconButton(onPressed: reload, icon: const Icon(Icons.refresh))]),
    floatingActionButton: FloatingActionButton.extended(onPressed: add, icon: const Icon(Icons.add), label: const Text('إضافة')),
    body: FutureBuilder<List<dynamic>>(future: future, builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
      if (snapshot.hasError) return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.cloud_off, size: 48, color: Colors.redAccent), const SizedBox(height: 12), Text('${snapshot.error}', textAlign: TextAlign.center), TextButton(onPressed: reload, child: const Text('إعادة المحاولة'))])));
      final rows = snapshot.data ?? [];
      if (rows.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 52, color: Colors.black26), const SizedBox(height: 12), const Text('مازال ما كاينة حتى معلومة'), const SizedBox(height: 8), FilledButton.icon(onPressed: add, icon: const Icon(Icons.add), label: const Text('أضف أول عنصر'))]));
      return RefreshIndicator(onRefresh: () async => reload(), child: ListView.separated(padding: const EdgeInsets.fromLTRB(14,14,14,90), itemCount: rows.length, separatorBuilder: (_,__) => const SizedBox(height: 9), itemBuilder: (context,i) {
        final item = Map<String,dynamic>.from(rows[i] as Map);
        final title = item['name'] ?? (widget.type == '/apartments' ? 'الشقة ${item['number']}' : widget.type == '/payments' ? 'أداء رقم ${item['id']}' : widget.type == '/expenses' ? item['title'] : item['title']) ?? 'عنصر ${item['id']}';
        final imageUrl = item['image_url']?.toString() ?? '';
        return Card(child: ListTile(contentPadding: const EdgeInsets.all(12), leading: imageUrl.isNotEmpty ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(imageUrl, width: 58, height: 58, fit: BoxFit.cover, errorBuilder: (_,__,___) => _avatar())) : _avatar(), title: Text('$title', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Padding(padding: const EdgeInsets.only(top:5), child: Text(subtitle(item), textAlign: TextAlign.right)), trailing: Text('#${item['id']}', style: const TextStyle(color: Colors.black45))));
      }));
    }),
  );
  Widget _avatar() => CircleAvatar(backgroundColor: const Color(0xFFE5F2ED), child: Icon(icon, color: const Color(0xFF247A62)));
}

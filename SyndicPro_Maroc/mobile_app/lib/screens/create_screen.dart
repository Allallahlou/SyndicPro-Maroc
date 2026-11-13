import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CreateScreen extends StatefulWidget {
  final String type;
  final String title;
  const CreateScreen({super.key, required this.type, required this.title});
  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final formKey = GlobalKey<FormState>();
  final fields = <String, TextEditingController>{};
  bool saving = false;
  String? message;

  List<(String, String, String)> get definitions {
    switch (widget.type) {
      case '/buildings': return [('name','اسم العمارة','text'),('address','العنوان','text'),('city','المدينة','text'),('monthly_fee','واجب السانديك الشهري (DH)','number'),('image_url','رابط صورة العمارة (اختياري)','text')];
      case '/apartments': return [('building_id','رقم العمارة (ID)','number'),('number','رقم الشقة','text'),('floor','الطابق','number'),('owner_name','اسم المالك','text'),('phone','رقم الهاتف','phone'),('image_url','رابط صورة الشقة (اختياري)','text')];
      case '/payments': return [('apartment_id','رقم الشقة (ID)','number'),('amount','المبلغ بالدرهم','number'),('period','الفترة مثال 2026-11','text'),('method','طريقة الأداء (cash / bank / transfer)','text'),('reference','مرجع الأداء','text')];
      case '/expenses': return [('building_id','رقم العمارة (ID)','number'),('title','عنوان المصروف','text'),('category','الصنف','text'),('amount','المبلغ بالدرهم','number'),('supplier','المورد','text'),('invoice_ref','مرجع الفاتورة','text')];
      default: return [('building_id','رقم العمارة (ID)','number'),('apartment_id','رقم الشقة (ID) اختياري','optionalNumber'),('title','عنوان الشكاية','text'),('description','شرح المشكلة','multiline'),('category','نوع المشكلة (تسرب/مصعد/نظافة...)','text'),('assigned_to','المكلف بالإصلاح','text')];
    }
  }

  @override
  void initState() { super.initState(); for (final f in definitions) { fields[f.$1] = TextEditingController(); } }
  @override
  void dispose() { for (final c in fields.values) { c.dispose(); } super.dispose(); }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    setState(() { saving = true; message = null; });
    try {
      final body = <String, dynamic>{};
      for (final f in definitions) {
        final key = f.$1; final value = fields[key]!.text.trim();
        if (value.isEmpty && f.$3 == 'optionalNumber') continue;
        if (f.$3 == 'number' || f.$3 == 'optionalNumber') body[key] = int.tryParse(value) ?? double.tryParse(value) ?? 0;
        else body[key] = value;
      }
      if (widget.type == '/payments') { body['paid_on'] = DateTime.now().toIso8601String().substring(0,10); body['method'] = body['method'].toString().isEmpty ? 'cash' : body['method']; }
      if (widget.type == '/expenses') body['spent_on'] = DateTime.now().toIso8601String().substring(0,10);
      await ApiService.post(widget.type, body);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ بنجاح')));
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() { message = e.toString(); });
    } finally { if (mounted) setState(() { saving = false; }); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('إضافة ${widget.title}')),
    body: Form(key: formKey, child: ListView(padding: const EdgeInsets.all(16), children: [
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFE5F2ED), borderRadius: BorderRadius.circular(16)), child: const Text('عمّر المعلومات التالية. الحقول الاختيارية يمكن تركها فارغة.', textAlign: TextAlign.right)),
      const SizedBox(height: 16),
      ...definitions.map((f) => Padding(padding: const EdgeInsets.only(bottom: 13), child: TextFormField(
        controller: fields[f.$1], maxLines: f.$3 == 'multiline' ? 4 : 1,
        keyboardType: ['number','optionalNumber'].contains(f.$3) ? const TextInputType.numberWithOptions(decimal: true) : f.$3 == 'phone' ? TextInputType.phone : TextInputType.text,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(labelText: f.$2, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
        validator: (v) => (v == null || v.trim().isEmpty) && f.$3 != 'optionalNumber' && !f.$1.contains('image_url') && !['address','city','period','reference','supplier','invoice_ref','assigned_to','description','phone'].contains(f.$1) ? 'هذا الحقل مطلوب' : null,
      ))),
      if (message != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(message!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center)),
      SizedBox(height: 52, child: FilledButton.icon(onPressed: saving ? null : save, icon: saving ? const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)) : const Icon(Icons.save), label: const Text('حفظ العملية'))),
    ])),
  );
}

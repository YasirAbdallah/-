import 'package:arabic_font/arabic_font.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paligolshir/controllers/auth_controller.dart';
import 'package:paligolshir/views/helpers/app_widgets.dart';

class AdminManagementPage extends StatelessWidget {
  final UserController adminController = Get.put(UserController());

  AdminManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
            data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(0.9)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const CustomTitleText(text: 'إدارة المدراء'),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFFD700), // اللون الذهبي الأساسي
                    Color(0xFFFFC107), // لون ذهبي أفتح
                    Color(0xFFFFD700), // لون برتقالي ذهبي
                    Color(0xFFCC8400), // لون ذهبي داكن
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          body: Obx(() {
            if (adminController.admins.isEmpty) {
              return const Center(child: Text('لا يوجد مدراء حالياً'));
            }
      
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: adminController.admins.length,
                itemBuilder: (context, index) {
                  final admin = adminController.admins[index];
                  return Card(
                    shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                        decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFFD700),
                            Color(0xFFFFC107),
                            Color(0xFFFFD700),
                            Color(0xFFCC8400),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                                          child: ListTile(
                        title: CustomBodyText(
                          text: admin.name,
                        ), // عرض اسم المدير
                        subtitle: CustomBodyText(
                            text: admin.email), // عرض البريد الإلكتروني
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteConfirmationDialog(context, admin.email);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
          floatingActionButton: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFD700),
                  Color(0xFFFFC107),
                  Color(0xFFFFD700),
                  Color(0xFFCC8400),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: FloatingActionButton(
              onPressed: () async {
                Map<String, String>? adminData =
                    await _showAddAdminDialog(context);
                if (adminData != null) {
                  adminController.addAdmin(adminData['email']!,
                      adminData['name']!); // تمرير البريد والاسم
                }
              },
              backgroundColor: Colors.transparent, // خلفية شفافة لإظهار التدرج
              elevation: 0, // إزالة الظل ليبدو أكثر تكاملاً مع التدرج
      
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
  }


Future<Map<String, String>?> _showAddAdminDialog(BuildContext context) {
    String email = '';
    String name = '';

    return showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              'إضافة مدير جديد',
              style: ArabicTextStyle(
                arabicFont: ArabicFont.changa,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'اسم المدير',
                    hintStyle: ArabicTextStyle(
                      arabicFont: ArabicFont.changa,
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    name = value;
                  },
                ),
                const SizedBox(height: 15),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'البريد الإلكتروني',
                    hintStyle: ArabicTextStyle(
                      arabicFont: ArabicFont.changa,
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    email = value;
                  },
                ),
              ],
            ),
            actions: <Widget>[
              // زر إلغاء بتصميم أنيق
              TextButton.icon(
                icon: const Icon(Icons.cancel, color: Colors.grey),
                label: const Text(
                  'إلغاء',
                  style: ArabicTextStyle(
                    arabicFont: ArabicFont.changa,
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // إغلاق الحوار
                },
              ),

              // زر إضافة مع تدرج ذهبي
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFD700), // لون ذهبي
                      Color(0xFFFFC107), // لون ذهبي فاتح
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                  ),
                  label: const Text(
                    'إضافة',
                    style: ArabicTextStyle(
                      arabicFont: ArabicFont.changa,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop({
                      'name': name,
                      'email': email,
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

void _showDeleteConfirmationDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // حواف دائرية للإطار
            ),
            title: const Text(
              'تأكيد الحذف',
              style: ArabicTextStyle(
                arabicFont: ArabicFont.changa,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            content: Text(
              'هل تريد حذف المدير $email؟',
              style: const ArabicTextStyle(
                arabicFont: ArabicFont.changa,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            actions: <Widget>[
              // زر إلغاء
              ElevatedButton.icon(
                icon: const Icon(Icons.cancel, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20), backgroundColor: Colors.grey, // لون رمادي للإلغاء
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                label: const Text(
                  'إلغاء',
                  style: ArabicTextStyle(
                    arabicFont: ArabicFont.changa,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // إغلاق الحوار
                },
              ),

              // زر حذف بلون ذهبي متدرج
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFD700), // ذهبي
                      Color(0xFFFFC107), // ذهبي فاتح
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, // شفاف للسماح بالتدرج
                    shadowColor: Colors.transparent, // بدون ظل لتنسيق التدرج
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  ),
                  label: const Text(
                    'حذف',
                    style: ArabicTextStyle(
                      arabicFont: ArabicFont.changa,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    adminController.deleteAdmin(email); // حذف المدير
                    Navigator.of(context).pop(); // إغلاق الحوار
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}

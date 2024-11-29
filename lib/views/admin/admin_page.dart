import 'package:arabic_font/arabic_font.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:paligolshir/controllers/auth_controller.dart';
import 'package:paligolshir/controllers/poem_controller.dart';
import 'package:paligolshir/models/poem_model.dart';
import 'package:paligolshir/views/admin/admin_add_lines_page.dart';
import 'package:paligolshir/views/admin/admin_management_page.dart';
import 'package:paligolshir/views/admin/admin_poem_info_page.dart';
import 'package:paligolshir/views/admin/admin_poem_page.dart';
import 'package:paligolshir/views/admin/admin_recscive_payment_page.dart';
import 'package:paligolshir/views/helpers/app_widgets.dart';
import 'package:paligolshir/views/helpers/font_adjuster.dart';
import 'package:paligolshir/views/user/user_search_page.dart';

class AdminPage extends StatefulWidget {
  final PoemController poemController = Get.put(PoemController());
  final UserController _userController = Get.put(UserController());

  AdminPage({super.key});

  @override
  AdminPageState createState() => AdminPageState();
}

class AdminPageState extends State<AdminPage> {
  Rx<Poem?>? poem; // إنشاء متغير لتخزين الـ Poem

  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    poem = widget.poemController.poem; // الوصول إلى الـ poem هنا بعد التهيئة
  }

  // قم بتعريف الـ widgetOptions داخل الـ build بدلاً من جعله static
  List<Widget> get _widgetOptions => <Widget>[
        AdminPoemPage(),
        AdminPoemInfoPage(poem: poem!), // استخدام الـ poem هنا بعد التهيئة
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // بناء Drawer
  Widget _buildDrawer(BuildContext context) {
    double fontSize = FontAdjuster.getAdjustedFontSize(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Obx(
            () {
              var userInfo = widget._userController.currentUser;
              return DrawerHeader(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(userInfo?.photoURL ?? ''),
                    ),
                    const SizedBox(height: 5),
                    AutoSizeText(
                      maxLines: 1, // عدد الأسطر الأقصى
                      minFontSize: 10, // الحجم الأدنى للنص
                      maxFontSize: 15, // الحجم الأقصى للنص
                      overflow: TextOverflow.ellipsis, // التعامل مع النص الزائد
                      userInfo?.username ?? 'Guest',
                      style: ArabicTextStyle(
                        color: const Color(0xFF32527B),
                        arabicFont: ArabicFont.dinNextLTArabic,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    AutoSizeText(
                      maxLines: 1, // عدد الأسطر الأقصى
                      minFontSize: 10, // الحجم الأدنى للنص
                      maxFontSize: 15, // الحجم الأقصى للنص
                      overflow: TextOverflow.fade, // التعامل مع النص الزائد
                      userInfo?.email ?? '',
                      style: ArabicTextStyle(
                        color: const Color(0xFF32527B),
                        arabicFont: ArabicFont.dinNextLTArabic,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Card(
            margin: const EdgeInsets.all(5),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFD700), // اللون الذهبي الأساسي
                    Color(0xFFFFC107), // لون ذهبي أفتح
                    Color(0xFFFFD700), // لون برتقالي ذهبي
                    Color(0xFFCC8400), // لون ذهبي داكن
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.add_circle,
                  color: Color(0xFF32527B),
                ),
                title: const CustomBodyText(
                  text: 'إضافة بيت ',
                ),
                onTap: () {
                  Get.back();
                  Get.to(AdminAddLinesPage());
                },
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.all(5),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFD700), // اللون الذهبي الأساسي
                    Color(0xFFFFC107), // لون ذهبي أفتح
                    Color(0xFFFFD700), // لون برتقالي ذهبي
                    Color(0xFFCC8400), // لون ذهبي داكن
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.info,
                  color: Color(0xFF32527B),
                ),
                title: const CustomBodyText(
                  text: 'معلومات حول القصيدة',
                ),
                onTap: () {
                  Get.back();
                  Get.to(AdminPoemInfoPage(
                    poem: widget.poemController.poem,
                  ));
                },
              ),
            ),
          ),

          Card(
            margin: const EdgeInsets.all(5),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFD700), // اللون الذهبي الأساسي
                    Color(0xFFFFC107), // لون ذهبي أفتح
                    Color(0xFFFFD700), // لون برتقالي ذهبي
                    Color(0xFFCC8400), // لون ذهبي داكن
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.notifications_active,
                  color: Color(0xFF32527B),
                ),
                title: const CustomBodyText(
                  text: 'الإشعارات',
                ),
                onTap: () {
                  Get.back();
                  Get.to(const AdminReceivePaymentPage());
                },
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.all(5),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFD700), // اللون الذهبي الأساسي
                    Color(0xFFFFC107), // لون ذهبي أفتح
                    Color(0xFFFFD700), // لون برتقالي ذهبي
                    Color(0xFFCC8400), // لون ذهبي داكن
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading:
                    const Icon(Icons.manage_accounts, color: Color(0xFF32527B)),
                title: const CustomBodyText(
                  text: 'الإدارة',
                ),
                onTap: () async {
                  Get.back(); // الرجوع للقائمة الجانبية
                  Get.to(AdminManagementPage());
                },
              ),
            ),
          ),
          // زر تسجيل الخروج
          Card(
            margin: const EdgeInsets.all(5),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFD700), // اللون الذهبي الأساسي
                    Color(0xFFFFC107), // لون ذهبي أفتح
                    Color(0xFFFFD700), // لون برتقالي ذهبي
                    Color(0xFFCC8400), // لون ذهبي داكن
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFF32527B)),
                title: const CustomBodyText(
                  text: 'تسجيل الخروج',
                ),
                onTap: () async {
                  await widget._userController
                      .signOut(); // استدعاء دالة تسجيل الخروج
                  Get.back(); // الرجوع للقائمة الجانبية
                  Get.offNamed('/'); // أو أي صفحة تانية بعد تسجيل الخروج
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
            data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(0.9)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          drawer: _buildDrawer(context),
          appBar: AppBar(
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                    onPressed: () {
                      Get.to(UserSearchPage());
                    },
                    icon: const Icon(
                      Icons.search,
                      size: 30,
                      color: metallicBlue,
                    )),
              )
            ],
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
            title: const CustomTitleText(
              text: 'بليغ الشعر',
            ),
          ),
          body: _widgetOptions.elementAt(_selectedIndex),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  color: Colors.black.withOpacity(.1),
                )
              ],
            ),
            child: Container(
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
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                  child: GNav(
                    rippleColor: const Color(0xFFFFC107),
                    hoverColor: const Color.fromARGB(255, 254, 241, 201),
                    gap: 8,
                    activeColor: const Color(0xFF32527B),
                    iconSize: 24,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    duration: const Duration(milliseconds: 400),
                    tabBackgroundColor: const Color.fromARGB(255, 255, 230, 154),
                    color: const Color(0xFF32527B),
                    tabs: const [
                      GButton(
                        textStyle: ArabicTextStyle(
                            arabicFont: ArabicFont.changa,
                            color: Color(0xFF32527B),
                            fontWeight: FontWeight.bold),
                        icon: Icons.list,
                        text: 'جميع الابيات',
                      ),
                      GButton(
                        textStyle: ArabicTextStyle(
                            arabicFont: ArabicFont.changa,
                            color: Color(0xFF32527B),
                            fontWeight: FontWeight.bold),
                        icon: Icons.comment,
                        text: 'وصف القصيدة',
                      ),
                    ],
                    selectedIndex: _selectedIndex,
                    onTabChange: _onItemTapped,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

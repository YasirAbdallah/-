import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:paligolshir/controllers/auth_controller.dart';
import 'package:paligolshir/controllers/poem_controller.dart';
import 'package:paligolshir/views/admin/admin_add_lines_page.dart';
import 'package:paligolshir/views/user/user_pay_page.dart';
import 'package:paligolshir/views/user/user_poem_page.dart';

class UserPage extends StatefulWidget {
  final PoemController poemController = Get.put(PoemController());
  final UserController _userController = Get.put(UserController());
  UserPage({super.key});

  @override
  UserPageState createState() => UserPageState();
}

class UserPageState extends State<UserPage> {
  int _selectedIndex = 0;
  // قائمة الخيارات التي يتم عرضها بناءً على الـ tab المختار
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    // جلب userId من PoemController وتمريره إلى UserPayPage
    widget._userController.loadUserFromPreferences();

    // تحديث قائمة الواجهات بناءً على userId
    _widgetOptions = <Widget>[
      UserPoemPage(),
      AdminAddLinesPage(),
      UserPayPage(), // تمرير userId إلى صفحة الدفع
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var userInfo = widget._userController.currentUser;
    return Scaffold(
      appBar: AppBar(
        primary: true,
        backgroundColor: Colors.blue,
        title: const Text(
          'لوحة التحكم',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.green,
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
                  Text(
                    userInfo?.username ?? 'Guest',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    userInfo?.email ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('قائمة المنتجات'),
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('سلة المشتريات'),
              onTap: () {
                Get.to(UserPayPage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('البحث عن منتج'),
              onTap: () {
                Get.to(UserPayPage());
              },
            ),
          ],
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.blue,
              hoverColor: Colors.blue,
              gap: 8,
              activeColor: Colors.white,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.blue[600]!,
              color: const Color.fromARGB(255, 16, 88, 18),
              tabs: const [
                GButton(
                  icon: Icons.list,
                  text: 'جميع الابيات',
                ),
                GButton(
                  icon: Icons.add_card,
                  text: 'اضافة بيت',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}

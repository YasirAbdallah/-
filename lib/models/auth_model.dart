// ignore_for_file: empty_catches, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paligolshir/models/admin_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel {
  final String uid;
  final String email;
  final bool isAdmin;
  final String? photoURL;
  final String? username;

  UserModel({
    required this.uid,
    required this.email,
    required this.isAdmin,
    this.photoURL,
    this.username,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'isAdmin': isAdmin,
      'photoURL': photoURL,
      'username': username,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      isAdmin: map['isAdmin'],
      photoURL: map['photoURL'],
      username: map['username'],
    );
  }
}

// خدمة المصادقة


class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        bool isAdmin = await _checkAdmin(userCredential.user!.email!);

        // جلب الاسم من حساب Google
        String? username = googleUser.displayName;

        final user = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email!,
          isAdmin: isAdmin,
          photoURL: userCredential.user!.photoURL,
          username: username,
        );
        final paymentsDocRef = _firestore.collection('payments').doc(user.uid);
        // حفظ بيانات المستخدم في قاعدة البيانات
        await _firestore.collection('users').doc(user.uid).set(user.toMap());

        // حفظ بيانات المستخدم في SharedPreferences
        await saveUserToPreferences(user);

        if (isAdmin == false) {
          final docSnapshot = await paymentsDocRef.get();

          if (docSnapshot.exists) {
            // إذا كانت الوثيقة موجودة، نقوم بتحديث البيانات
            await paymentsDocRef.update({
              'userId': user.uid,
              'userName': user.username,
              'userEmail': user.email,
              'userPhoto': user.photoURL ?? '',
            });
            print('تم تحديث بيانات الدفع بنجاح.');
          } else {
            // إذا كانت الوثيقة غير موجودة، نقوم بإنشائها باستخدام set
            await paymentsDocRef.set({
              'userId': user.uid,
              'userName': user.username,
              'userEmail': user.email,
              'userPhoto': user.photoURL ?? '',
            });
            print('تم إنشاء وثيقة الدفع وتخزين البيانات بنجاح.');
          }
        }

        return user;
      }
    } catch (e) {}
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    // إزالة بيانات المستخدم من SharedPreferences عند تسجيل الخروج
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> _checkAdmin(String email) async {
    DocumentSnapshot snapshot = await _firestore.collection('admins').doc(email).get();
    return snapshot.exists;
  }

  Future<void> saveUserToPreferences(UserModel user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', user.uid);
    await prefs.setString('email', user.email);
    await prefs.setBool('isAdmin', user.isAdmin);
    await prefs.setBool('isLoggedIn', true); // حفظ حالة تسجيل الدخول
    if (user.photoURL != null) {
      await prefs.setString('photoURL', user.photoURL!);
    }
    if (user.username != null) {
      await prefs.setString('username', user.username!);
    }
  }

  // إضافة مدير
  Future<void> addAdmin(Admin admin) async {
    try {
      await _firestore.collection('admins').doc(admin.email).set(admin.toMap());
    } catch (e) {
      print('Error adding admin: $e');
      rethrow; // إعادة الخطأ
    }
  }

  // حذف مدير
  Future<void> deleteAdmin(String email) async {
    try {
      await _firestore.collection('admins').doc(email).delete();
      // استعلام Firestore للحصول على الوثيقة التي تحتوي على البريد الإلكتروني
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      // التحقق من وجود الوثيقة قبل تحديثها
      if (querySnapshot.docs.isNotEmpty) {
        // تحديث حقل isAdmin في الوثيقة المسترجعة
        await querySnapshot.docs.first.reference.update({
          'isAdmin': false,
        });
      }
    } catch (e) {
      print('Error deleting admin: $e');
      // ignore: use_rethrow_when_possible
      throw e; // إعادة الخطأ
    }
  }

  // تحويل دالة getAdmins إلى Stream
  Stream<List<Admin>> getAdmins() {
    return _firestore.collection('admins').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Admin.fromMap(doc.data())).toList();
    });
  }

  String? getUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    return user
        ?.uid; // إذا كان هناك مستخدم، يتم إرجاع الـ user ID، وإذا لم يكن هناك يتم إرجاع null
  }

  Future<String?> getUidByEmail(String email) async {
    try {
      // استعلام Firestore للحصول على الوثيقة التي تحتوي على البريد الإلكتروني
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      // التحقق من الوثيقة المسترجعة
      if (querySnapshot.docs.isNotEmpty) {
        // استرجاع userId من الحقل الموجود
        return querySnapshot.docs.first.get('uid') as String?;
      } else {
        return null; // لم يتم العثور على مستخدم بالبريد المحدد
      }
    } catch (e) {
      print('Error fetching userId by email: $e');
      return null;
    }
  }
}

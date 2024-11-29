import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:paligolshir/controllers/auth_controller.dart';
import 'package:paligolshir/views/helpers/app_widgets.dart';

const Color metallicBlue = Color(0xFF4F4D8C);
const double imageHeight = 250.0; // Height for the images
const double textSpacing = 60.0; // Spacing between the image and text

class SignInPage extends StatelessWidget {
  final UserController userController = Get.put(UserController());

  SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
            data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(0.9)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(),
          body: IntroductionScreen(
            pages: [
              _buildIntroPage(),
              _buildSponsorshipPage(),
              _buildSignInPage(),
            ],
            showSkipButton: true,
            showDoneButton: false,
            skip: const Text("تخطي", style: TextStyle(color: metallicBlue)),
            next: const Icon(Icons.arrow_forward, color: metallicBlue),
            dotsDecorator: DotsDecorator(
              activeColor: metallicBlue,
              size: const Size.square(10.0),
              activeSize: const Size(20.0, 10.0),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // الصفحة الأولى: مقدمة عن التطبيق
  PageViewModel _buildIntroPage() {
    return PageViewModel(
      titleWidget: const CustomTitleText(text: 'مرحباً بك في تطبيق بليغ الشعر'),
      bodyWidget: _buildImageWithText(
        image: 'assets/photos/logo.png',
        text: 'تطبيق قصيدة بليغ الشعر للشاعر محمد عبد العليم يوفر شرح وبيان لأبيات القصيدة التي تضم جميع علوم البلاغة والقواعد العربية على هيئة أمثلة تفصيلية متخذة الشعر موضوعا لها مع الإستماع للبيت صوتيا ومزايا أخرى . ',
      ),
      decoration: const PageDecoration(
        imagePadding: EdgeInsets.only(top: 16.0),
      ),
    );
  }

  // الصفحة الثانية: تعريف برعاية التطبيق
  PageViewModel _buildSponsorshipPage() {
    return PageViewModel(
      // image: Image.asset("assets/photos/logo.png", fit: BoxFit.cover),
      titleWidget:
          const CustomTitleText(text: 'بإشراف مركز بيرمنقهام للغات'),
      bodyWidget: _buildImageWithText(
        image: 'assets/photos/btc.png',
        text: 'مركز بيرمنقهام للغات يعنى بتطوير اللغات ونشر ثقافة التعليم بالوسائط المتعددة وتطوير المناهج التعليمية '
            '.',
      ),

      decoration: const PageDecoration(
        imagePadding: EdgeInsets.only(top: 16.0),
      ),
    );
  }

  // الصفحة الثالثة: تسجيل الدخول
  PageViewModel _buildSignInPage() {
    return PageViewModel(
      // image: Image.asset("assets/photos/login_logo.png", fit: BoxFit.cover),
      titleWidget:
          const CustomTitleText(text: 'يرجى تسجيل الدخول للاستفادة من التطبيق'),
      bodyWidget: Column(
        children: [
          _buildImageWithText(
            image: 'assets/photos/login_logo.png',
            text: 'يمكنك تسجيل الدخول باستخدام حسابك في Google للوصول السريع '
                'والمضمون إلى جميع مزايا التطبيق التي نقدمها لك.',
          ),
          const SizedBox(height: 20),
          Obx(
            () {
              return userController.isLoading.value
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: SizedBox(
                          height: 5.0, // تحديد ارتفاع الخط
                          child: LinearProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                metallicBlue), // اللون الذهبي
                            backgroundColor:
                                Colors.transparent, // الخلفية شفافة
                          ),
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await userController.signInWithGoogle();
                        } catch (e) {
                          if (kDebugMode) {
                            print('Error during sign-in: $e');
                          }
                        }
                      },
                      label: const CustomBodyText(
                        text: 'تسجيل الدخول بواسطة Google',
                      ),
                      icon: const Icon(
                        Icons.login,
                        color: metallicBlue,
                      ),
                    );
            },
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => _showPrivacyPolicyDialog(),
            // ignore: prefer_const_constructors
            child: CustomBodyText(
              text: ' شروط الخصوصية والاستخدام',
            ),
          ),
        ],
      ),
      decoration: const PageDecoration(
        imagePadding: EdgeInsets.only(top: 16.0),
      ),
    );
  }

  void _showPrivacyPolicyDialog() {
    Get.dialog(
      SingleChildScrollView(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const CustomTitleText(text: 'شروط الخصوصية والاستخدام'),
            content: const CustomSBodyText(
              text: '''
مرحبًا بك في تطبيق بليغ الشعر. تضع هذه الشروط والخصوصية القواعد المتعلقة باستخدامك للتطبيق، وكيفية جمع معلوماتك واستخدامها وحمايتها.

1. الموافقة على الشروط
باستخدام التطبيق، توافق على الالتزام بهذه الشروط والخصوصية. إذا لم توافق على أي من الشروط، يجب عليك عدم استخدام التطبيق.

2. جمع المعلومات الشخصية
نقوم بجمع المعلومات الشخصية عند تسجيلك في التطبيق، بما في ذلك ولكن لا تقتصر على:
- الاسم
- عنوان البريد الإلكتروني

3. استخدام المعلومات
نستخدم المعلومات التي نجمعها لأغراض متعددة، بما في ذلك:
- تحسين تجربة المستخدم
- تخصيص المحتوى والعروض
- إرسال تحديثات حول التطبيق

4. بيانات المستخدم
قد يتم جمع بيانات إضافية تتعلق بكيفية استخدامك للتطبيق، مثل:
- مدة الاستخدام
- الصفحات التي قمت بزيارتها
- التفاعلات داخل التطبيق

5. تسجيل الدخول بواسطة Google
يمكنك التسجيل وتسجيل الدخول إلى التطبيق باستخدام حساب Google الخاص بك. سنقوم بجمع المعلومات الضرورية لتسهيل عملية التسجيل، مثل:
- الاسم
- عنوان البريد الإلكتروني

لن نشارك معلومات حساب Google الخاص بك مع أطراف ثالثة دون إذن مسبق.

6. الاحتفاظ بالمعلومات
سنحتفظ بمعلوماتك الشخصية طالما كان ذلك ضروريًا لتحقيق الأغراض الموضحة في هذه الشروط.

7. حماية المعلومات
نحن نتخذ تدابير أمنية معقولة لحماية معلوماتك الشخصية من الوصول غير المصرح به أو الاستخدام أو التغيير. ومع ذلك، لا يمكن ضمان الأمان المطلق على الإنترنت.

8. مشاركة المعلومات مع أطراف ثالثة
لن نقوم ببيع أو تأجير معلوماتك الشخصية لأطراف ثالثة. قد نقوم بمشاركة المعلومات مع مزودي خدمات موثوقين لمساعدتنا في تشغيل التطبيق وتحليل البيانات.

9. التعديلات على الشروط
نحتفظ بالحق في تعديل هذه الشروط في أي وقت. سيتم إبلاغك بأي تغييرات عبر التطبيق. استمرارك في استخدام التطبيق بعد إجراء التغييرات يعتبر موافقة على الشروط المعدلة.

10. اتصل بنا
إذا كان لديك أي استفسارات حول هذه الشروط أو الخصوصية، يمكنك الاتصال بنا على:
- البريد الإلكتروني: [paligolshirabb@gmail.com]
- رقم الهاتف: [249910005619]

''',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const CustomBodyText(text: 'موافق'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة لبناء صورة مع نص
  Widget _buildImageWithText({required String image, required String text}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset(image, height: imageHeight, fit: BoxFit.cover),
            const SizedBox(height: textSpacing),
            CustomBodyText(text: text),
          ],
        ),
      ),
    );
  }
}

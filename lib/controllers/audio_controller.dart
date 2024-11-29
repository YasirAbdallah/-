import 'package:get/get.dart';

class AudioController extends GetxController {
  var selectedAudio = Rx<String?>(null);

  void changeAudioSource(String newAudioSource) {
    selectedAudio.value = newAudioSource;
  }
}

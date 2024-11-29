// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:paligolshir/views/helpers/app_widgets.dart';
import 'package:paligolshir/views/helpers/voice_wave.dart';

class FileVoiceCardPlayer extends StatefulWidget {
  final String audioSource;
  const FileVoiceCardPlayer({super.key, required this.audioSource});

  @override
  _FileVoiceCardPlayerState createState() => _FileVoiceCardPlayerState();
}

class _FileVoiceCardPlayerState extends State<FileVoiceCardPlayer> {
  final audioSource = ''.obs; // Use RxString for audio source
  late final AudioPlayer _audioPlayer;
  var isPlaying = false.obs;
  var isLoading = false.obs;
  var currentPosition = Duration.zero.obs;
  var totalDuration = Duration.zero.obs;

  @override
  void initState() {
    super.initState();
    audioSource.value = widget.audioSource; // Initialize audio source
    _audioPlayer = AudioPlayer();
    _initializeAudio();
    _audioPlayer.positionStream.listen((position) {
      currentPosition.value = position;
    });
    _audioPlayer.durationStream.listen((duration) {
      totalDuration.value = duration ?? Duration.zero;
    });
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _audioCompleted();
      }
    });
  }

  Future<void> _initializeAudio() async {
    isLoading.value = true;
    try {
      String localPath = audioSource.value; // Use the local audio file path
      await _audioPlayer.setFilePath(localPath);
      totalDuration.value = _audioPlayer.duration ?? Duration.zero;
    } catch (e) {
      if (kDebugMode) {
        print("Error initializing audio: $e");
      }
    } finally {
      isLoading.value = false;
    }
  }

  void toggleAudio() async {
    isPlaying.value = !isPlaying.value; // Toggle playing state
    if (isPlaying.value) {
      await _audioPlayer.play();
    } else {
      await _audioPlayer.pause();
    }
  }

  void _audioCompleted() {
    isPlaying.value = false;
    _audioPlayer.seek(Duration.zero);
    _audioPlayer.stop();
  }

  void rewind() async {
    final newPosition = currentPosition.value - const Duration(seconds: 10);
    await _audioPlayer
        .seek(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  void forward() async {
    final newPosition = currentPosition.value + const Duration(seconds: 10);
    if (totalDuration.value.inSeconds > 0) {
      await _audioPlayer.seek(newPosition > totalDuration.value
          ? totalDuration.value
          : newPosition);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

   void _showAudioOptionsDialog() {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CustomGoldBodyText( text: "مقطع صوتي",
              ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Image.asset("assets/photos/logo.png", fit: BoxFit.cover),
                ),
                Obx(() => Slider(
                      activeColor: const Color(0xFFCC8400),
                      value: currentPosition.value.inSeconds.toDouble(),
                      min: 0.0,
                      max: totalDuration.value.inSeconds.toDouble(),
                      onChanged: (value) {
                        _audioPlayer.seek(Duration(seconds: value.toInt()));
                        currentPosition.value = Duration(seconds: value.toInt());
                      },
                    )),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => Text(
                            "${currentPosition.value.inMinutes}:${(currentPosition.value.inSeconds % 60).toString().padLeft(2, '0')}",
                            style: const TextStyle(color: Colors.grey),
                          )),
                      Obx(() => Text(
                            "${totalDuration.value.inMinutes}:${(totalDuration.value.inSeconds % 60).toString().padLeft(2, '0')}",
                            style: const TextStyle(color: Colors.grey),
                          )),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: rewind,
                      child:
                          const Icon(Icons.replay_10, color: Color(0xFFCC8400)),
                    ),
                    ElevatedButton(
                      onPressed: toggleAudio,
                      child: Obx(() {
                        return Icon(
                          isPlaying.value ? Icons.pause : Icons.play_arrow,
                          color: const Color(0xFFCC8400),
                        );
                      }),
                    ),
                    ElevatedButton(
                      onPressed: forward,
                      child:
                          const Icon(Icons.forward_10, color: Color(0xFFCC8400)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              isLoading.value
                  ? const CircularProgressIndicator()
                  : IconButton(
                      icon: Icon(
                        isPlaying.value
                            ? Icons.pause_circle
                            : Icons.play_circle,
                        size: 50.0,
                        color: Colors.orangeAccent,
                      ),
                      onPressed: toggleAudio,
                    ),
              Expanded(
                child: GestureDetector(
                  onTap: _showAudioOptionsDialog,
                  child: Card(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(
                                double.infinity, 45), // حجم عنصر CustomPaint
                            painter: WavePainter(
                              currentPosition, // الوقت الحالي
                              totalDuration, // المدة الكلية
                            ),
                          ),
                          Text(
                            "${currentPosition.value.inMinutes}:${(currentPosition.value.inSeconds % 60).toString().padLeft(2, '0')} / ${totalDuration.value.inMinutes}:${(totalDuration.value.inSeconds % 60).toString().padLeft(2, '0')}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

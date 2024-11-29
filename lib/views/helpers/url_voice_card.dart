import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:paligolshir/views/helpers/app_widgets.dart';
import 'package:paligolshir/views/helpers/voice_wave.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';


class UrlVoiceCardPlayer extends StatefulWidget {
  final String audioSource;
  const UrlVoiceCardPlayer({super.key, required this.audioSource});

  @override
  UrlVoiceCardPlayerState createState() => UrlVoiceCardPlayerState();
}

class UrlVoiceCardPlayerState extends State<UrlVoiceCardPlayer> {
  final _audioPlayer = AudioPlayer();
  final isPlaying = false.obs;
  final isLoading = false.obs;
  final currentPosition = Duration.zero.obs;
  final totalDuration = Duration.zero.obs;
  final RxList<double> samples = <double>[].obs;

  @override
  void initState() {
    super.initState();
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
String _generateShortMD5(String input) {
    return md5
        .convert(utf8.encode(input))
        .toString()
        .substring(0, 10); // استخدام أول 10 أحرف
  }
  Future<String> _downloadAndCacheAudio(String url) async {
    final dir = await getTemporaryDirectory();
    final uniqueFileName = _generateShortMD5(url); // استخدام MD5 للرابط لاسم فريد
    final filePath = "${dir.path}/$uniqueFileName.m4a";
    final cachedFile = File(filePath);

    try {
      //  final file = File(filePath);
      if (await cachedFile.exists()) {
        if (kDebugMode) {
          print(
              "###File already exists at: $filePath");
        }
        return cachedFile.path;
      } else {
    
        final response = await Dio().download(url, filePath);

        if (response.statusCode == 200) {
    
          if (kDebugMode) {
            print("Audio downloaded successfully to: $filePath");
          }
          return cachedFile.path;
        } else {
          if (kDebugMode) {
            print(
                "Failed to download audio. Status code: ${response.statusCode}");
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error downloading audio: $e");
      }
    }
    return '';
  }

  Future<void> _initializeAudio() async {
    isLoading.value = true;
    try {
      String localPath = await _downloadAndCacheAudio(widget.audioSource);
      await _audioPlayer.setFilePath(localPath);
      totalDuration.value = _audioPlayer.duration ?? Duration.zero;
      samples.addAll(await _extractSamples(localPath));
    } catch (e) {
      if (kDebugMode) {
        print("Error initializing audio: $e");
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<double>> _extractSamples(String filePath) async {
    List<double> audioSamples = [];
    for (int i = 0; i < 100; i++) {
      audioSamples.add(sin(i / 10.0));
    }
    return audioSamples;
  }

  void toggleAudio() async {
    isPlaying.value = !isPlaying.value;
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

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Card(
        elevation: 5,
        color: const Color(0xFFFFE1A8),
        margin: const EdgeInsets.all(10.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
        child: Row(
          children: [
            isLoading.value
                ? const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: CircularProgressIndicator(),
                  )
                : IconButton(
                    icon: Icon(
                      isPlaying.value ? Icons.pause_circle : Icons.play_circle,
                      size: 50.0,
                      color: const Color(0xFFCC8400),
                    ),
                    onPressed: toggleAudio,
                  ),
            const SizedBox(width: 20),
            Expanded(
              child: GestureDetector(
                onTap: _showAudioOptionsDialog,
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
                        size: const Size(double.infinity, 45),
                        painter: WavePainter(
                          currentPosition,
                          totalDuration,
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
          ],
        ),
      ),
    );
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
                const CustomGoldBodyText(
                  text: "مقطع صوتي",
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
}

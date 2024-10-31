import 'package:flutter_sound/flutter_sound.dart';
import 'package:audio_session/audio_session.dart';
import 'dart:async';

class AudioPlayer {
  FlutterSoundPlayer? _audioPlayer; // Agrega el reproductor de audio
  bool _isPlaying = false;

  Future<void> init() async {
    _audioPlayer = FlutterSoundPlayer(); // Inicializa el reproductor
    await _initPlayer(); // Inicializa el reproductor
  }

  // Función de inicialización del reproductor
  Future<void> _initPlayer() async {
    await _audioPlayer!.openPlayer();
    
    // Configura la sesión de audio para el reproductor
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.allowBluetooth,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
    ));
  }

  // Reproducir audio
  Future<void> playAudio(String path) async {
    if (_isPlaying) return;

    await _audioPlayer!.startPlayer(
      fromURI: path,
      codec: Codec.pcm16WAV, // Asegúrate de que el codec sea correcto
      whenFinished: () {
        _isPlaying = false; // Marca como no reproduciendo al finalizar
      },
    );

    _isPlaying = true;
    print('Reproduciendo audio desde: $path');
  }

  // Detener reproducción
  Future<void> stopPlaying() async {
    if (!_isPlaying) return;

    await _audioPlayer!.stopPlayer();
    _isPlaying = false;
    print('Reproducción detenida.');
  }

  // Liberar recursos al finalizar
  Future<void> dispose() async {
    await _audioPlayer!.closePlayer(); // Asegúrate de cerrar el reproductor también
  }
}

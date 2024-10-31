import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:audio_session/audio_session.dart';
import 'dart:async';
import 'dart:io';

class AudioRecorder {
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecording = false;

  Future<void> init() async {
    _audioRecorder = FlutterSoundRecorder();
    await _initRecorder();
  }

  // Función de inicialización
  Future<void> _initRecorder() async {
    // Solicitar permiso de grabación
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw Exception('Permiso de micrófono no otorgado');
    }

    // Inicializar el grabador
    await _audioRecorder!.openRecorder();

    // Configurar la sesión de audio
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.record,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
    ));
  }

  // Iniciar grabación
  Future<void> startRecording(String path) async {
    if (_isRecording) return;

    // Crea un archivo temporal en el directorio temporal del sistema
    // final tempDir = await getTemporaryDirectory();
    // final tempFile = File('${tempDir.path}/temp_recording.wav');

    //await _audioRecorder!.startRecorder(toFile: tempFile.path);
    print('Audio almacenado en: $path');
    await _audioRecorder!.startRecorder(toFile: path, codec: Codec.pcm16WAV);
    _isRecording = true;
  }

  // Detener grabación
  Future<void> stopRecording() async {
    if (!_isRecording) return;

    final path = await _audioRecorder!.stopRecorder();

    // Si path no es nulo, elimina el archivo temporal
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        print('Eliminando archivo temporal: $path');
        //await file.delete();
      }
    }
    _isRecording = false;
  }

  // Liberar recursos al finalizar
  Future<void> dispose() async {
    await _audioRecorder!.closeRecorder();
  }
}

import 'package:flutter/material.dart';
import 'package:myapp/AudioControllers/audio_player.dart';
import 'package:myapp/AudioControllers/audio_recorder.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'dart:io';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:audio_session/audio_session.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'dart:async';
// import 'dart:typed_data';

class PruebaRecorder extends StatefulWidget {
  const PruebaRecorder({super.key});

  @override
  State<PruebaRecorder> createState() => _IndexState();
}

class _IndexState extends State<PruebaRecorder> {
  late IO.Socket socket;
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initSocket();
    _initializeNotifications();
    _initializeAudioPlayer();
    _audioRecorder.init();
  }

  Future<void> _initializeAudioPlayer() async {
    await _audioPlayer.init(); // Asegúrate de inicializar el reproductor
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            '@mipmap/ic_launcher'); // Asegúrate de tener un icono

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String path) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your_channel_id', 'Your Channel Name',
            channelDescription: 'Your channel description',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, 'Grabación Detenida',
        'Archivo guardado en: $path', platformChannelSpecifics);
  }

  Future<void> _showNotification2() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your_channel_id', 'Your Channel Name',
            channelDescription: 'Your channel description',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, 'Reproduccion de audio',
        'Audio reproduciendose', platformChannelSpecifics);
  }

  void _initSocket() {
    socket = IO.io(
      'http://18.216.7.229:9002',
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      },
    );

    socket.onConnect((_) {
      print('Conectado al servidor');
    });

    socket.onConnectError((err) {
      print('Error de conexión: $err');
    });

    socket.onDisconnect((_) {
      print('Desconectado del servidor');
    });
  }

  @override
  void dispose() {
    socket.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transmisión de Audio'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                print('tapped');
                socket.emit('message', 'Hola desde Flutter');
              },
              child: const Text('Enviar mensaje'),
            ),
            const SizedBox(height: 20), // Espacio entre los botones
            GestureDetector(
              onLongPress: () async {
                print('Iniciar pruebas de audio');
                final directory = await getExternalStorageDirectory();
                if (directory != null) {
                  //final path = '${directory.path}/temp_recording.wav';
                  const path ='/storage/emulated/0/Download/temp_recording.wav';
                  print('Direccion: $path');
                  //await _showNotification(path);
                  await _audioRecorder.startRecording(path);
                } else {
                  // Manejar el caso en el que no se pudo obtener el directorio externo
                  print('No se pudo obtener el directorio externo');
                  // Por ejemplo, podrías mostrar un mensaje al usuario o usar una ruta alternativa
                }
                print('grabacion iniciada');
              },
              onLongPressEnd: (details) async {
                // Se ejecuta al soltar el botón
                print('Detener grabación');
                await _audioRecorder.stopRecording();
                print('grabacion detenida');

                await Future.delayed(const Duration(seconds: 3));
                String audioPath ='/storage/emulated/0/Download/temp_recording.wav';
                await _audioPlayer.playAudio(audioPath);
                _showNotification2();
                print('Reproduciendo audio después de 2 segundos');
              },
              child: ElevatedButton(
                // ElevatedButton como hijo del GestureDetector
                onPressed: () {}, // Desactiva el onPressed del ElevatedButton
                child: const Text('Audio'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

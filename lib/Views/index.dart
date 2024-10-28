import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class Index extends StatefulWidget {
  const Index({super.key});

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  late IO.Socket socket;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    // Inicializa y configura el socket

    socket = IO.io(
      'https://sockete.ddns.net',
      <String, dynamic>{
        'transports': ['websocket'], // Usa WebSockets como transporte
        'autoConnect': true, // Conexión automática
      },
    );

    

    // Escucha cuando se conecta
    socket.onConnect((_) {
      print('Conectado al servidor');
    });

    // Escucha errores de conexión
    socket.onConnectError((err) {
      print('Error de conexión: $err');
    });

    // Escucha desconexiones
    socket.onDisconnect((_) {
      print('Desconectado del servidor');
    });

    // Escucha la respuesta del servidor
    socket.on('response', (data) {
      print('Respuesta recibida del servidor: $data');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Envía un mensaje al servidor
          print('tapped');
          socket.emit('message', 'Hola desde Flutter!');
        },
        child: const Text('Enviar mensaje'),
      ),
    );
  }
}

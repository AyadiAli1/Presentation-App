import 'dart:io';

import 'package:flutter/foundation.dart';

Future<void> main() async {
  final ip = InternetAddress.anyIPv4;
  final server = await ServerSocket.bind(ip, 3000);
  print("Server is running on : ${ip.address}:3000");
  server.listen((Socket event) {
    handleConnection(event);
  });
}

List<Socket> clients = [];

handleConnection(Socket client) {
  client.listen((Uint8List data) {
    final message = String.fromCharCodes(data);
    clients.add(client);
    client.write("You are logged in as $message");
    for (final c in clients) {
      c.write("Client: $message joined the party");
    }
  }, onError: (error) {
    print(error);

    client.close();
  }, onDone: () {
    print("Server: Client left");

    client.close();
  });
}

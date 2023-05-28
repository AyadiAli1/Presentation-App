/*import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui show Image, ImageFilter, TextHeightBehavior;
export 'dart:ui' show Locale;
import 'dart:ui'
    show
        AccessibilityFeatures,
        AppExitResponse,
        AppLifecycleState,
        FrameTiming,
        Locale,
        PlatformDispatcher,
        TimingsCallback;
export 'dart:ui' show AppLifecycleState, Locale;
import 'dart:ui' show Color;
import 'dart:ui';
import 'dart:ui' show DisplayFeature, DisplayFeatureState;
import 'dart:ui' as ui hide TextStyle;

Future<void> main() async {
  
  final socket = await Socket.connect("0.0.0.0", 3000);

  print(
      'Server: Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');

  socket.listen((Uint8List data) {
    final serverResponse = String.fromCharCodes(data);
    print("Client : $serverResponse");
  }, onError: (error) {
    print("Client: $error");
    socket.destroy();
  }, onDone: () {
    print("Client: Server left.");
    socket.destroy();
  });
}
*/
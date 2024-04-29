import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shake/shake.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:welpoc/main.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //     FlutterLocalNotificationsPlugin();
  // late stt.SpeechToText _speech;
  // bool _isListening = false;
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _islisten = false;
  String _text = '';
  String _text1 = "Press button";
  double _confidence = 1.0;

  double long = 0.0;
  double lat = 0.0;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _speech = stt.SpeechToText();
    ShakeDetector.autoStart(
      onPhoneShake: () async {
        showToast("Shake! Shake!");
        Get.snackbar("Shake", "Shake");
        _getUserLocation();
        await Geolocator.requestPermission();
        await Permission.sms.request();
        await Permission.microphone.request();
        print("Send");
        await _sendSMS();
        _listen();
        // smsVm.getAndSendSMS();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Shake!')));
        // _speech = stt.SpeechToText();
        // _listen();
      },
      minimumShakeCount: 1,
      shakeSlopTimeMS: 500,
      shakeCountResetTime: 3000,
      shakeThresholdGravity: 2.7,
    );
  }

  @override
  // Widget build(BuildContext context) {
  //   return SafeArea(
  //     child: Scaffold(
  //       body: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           InkWell(
  //             onTap: () async {
  //               await _sendSMS();
  //               await Permission.microphone.request();
  //               print("Send");
  //             },
  //             child: Container(
  //               width: 100,
  //               height: 50,
  //               child: Text("tap"),
  //               color: Colors.red,
  //             ),
  //           ),
  //           Text(_text),
  //         ],
  //       ),
  //       floatingActionButton: FloatingActionButton(
  //         onPressed: () {
  //           _listen();
  //         },
  //         child: Icon(_islisten ? Icons.mic : Icons.mic_none),
  //       ),
  //     ),
  //   );
  // }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Women Safety App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                _sendSMS();
              },
              child: Container(
                width: 200,
                height: 200,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.redAccent, Colors.red],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sos, size: 80, color: Colors.white),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MyHomePage(title: "Welp")));
                  },
                  child: Text("Maps")),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: Colors.white),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _getUserLocation() async {
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      lat = position.latitude;
      long = position.longitude;
    });
    print("Lat $lat and long $long");
  }

  // void sendsms() async {
  //   List<String> num = ["+917037904015"];
  //   await sendSMS(message: "hey", recipients: num);
  // }

  showToast(String message, {bool error = false}) {
    if (kDebugMode) {
      print(" \n \n Print: \n $message \n ");
    }
    Fluttertoast.showToast(
        msg: message,
        fontSize: 14,
        backgroundColor: error == false ? Colors.black : Colors.red,
        textColor: Colors.white,
        gravity: ToastGravity.SNACKBAR,
        webPosition: 'center',
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 3);
  }

  void _listen() async {
    if (!_islisten) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          print('onStatus: $status');
        },
        onError: (error) {
          print('onError: $error');
          if (error.errorMsg == 'error_no_match') {
            // Handle the "error_no_match" error here
            setState(() {
              _text = "No speech recognized. Please try again.";
            });
          }
        },
      );

      if (available) {
        setState(() {
          _islisten = true;
        });
        _speech.listen(
          onResult: (result) {
            setState(() {
              _text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() {
        _islisten = false;
        _speech.stop();
      });
    }
  }

  Future<void> _sendSMS() async {
    String url = 'https://welp-backend.onrender.com/api/send-sms';
    Map<String, dynamic> requestBody = {
      "phoneNumber": "+919412166371",
      "message":
          "https://www.google.com/maps/@?api=1&map_action=map&center=$lat,$long",
    };

    try {
      http.Response response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print('SMS sent successfully');
        // Handle success
      } else {
        print('Failed to send SMS: ${response.body}');
        // Handle failure
      }
    } catch (e) {
      print('Error sending SMS: $e');
      // Handle error
    }
  }
}


  // void _showNotification() async {
  //   var android = AndroidNotificationDetails(
  //     'channel id',
  //     'channel name',
  //     'channel description',
  //     priority: Priority.high,
  //     importance: Importance.max,
  //   );
  //   var iOS = IOSNotificationDetails();
  //   var platform = NotificationDetails(android: android, iOS: iOS);
  //   await flutterLocalNotificationsPlugin.show(
  //     0,
  //     'WELP Detected',
  //     'The word "WELP" was spoken.',
  //     platform,
  //   );
  // }
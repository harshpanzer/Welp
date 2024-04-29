import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:latlong2/latlong.dart';

import 'maps_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: "Welp"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<dynamic> location1;
  late LatLng curr;
  late TextEditingController location = TextEditingController();
  int heart = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        // Column is also a layout widget. It takes a list of children and
        // arranges them vertically. By default, it sizes itself to fit its
        // children horizontally, and tries to be as tall as its parent.
        //
        // Column has various properties to control how it sizes itself and
        // how it positions its children. Here we use mainAxisAlignment to
        // center the children vertically; the main axis here is the vertical
        // axis because Columns are vertical (the cross axis would be
        // horizontal).
        //
        // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
        // action in the IDE, or press "p" in the console), to see the
        // wireframe for each widget.
        // mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 40,
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(15)),
            child: TextFormField(
              style: TextStyle(color: Color(0xff505050)),
              controller: location,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Invalid Location';
                } else if (value == null || value.isEmpty) {
                  return "Please enter the Location";
                }

                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.location_on),
                prefixIconColor: Color(0xff545454),
                // filled: true,
                // fillColor: Color(0xffffffff),
                enabledBorder: InputFormfieldBorder,
                focusedBorder: InputFormfieldBorder,
                errorBorder: InputFormfieldBorder,
                focusedErrorBorder: InputFormfieldBorder,
                border: InputFormfieldBorder,
                hintText: "Location",
                hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff505050)),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 0, vertical: 18),
              ),
            ),
          ),
          SizedBox(
            height: 40,
          ),
          ElevatedButton(
              onPressed: () async {
                location1 = await loc();
                print(location1);
                await getLocation();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MapScreen(
                        location: [curr.latitude, curr.longitude],
                        location1: location1)));
              },
              child: Text("Search")),
          SizedBox(
            height: 50,
          ),
          Text(heart.toString()),
          SizedBox(
            height: 20,
          ),
          TextButton(
              onPressed: () async {
                heart = await heartbeat();
                setState(() {
                  heart;
                });
              },
              child: Text("Get HeartBeat"))
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  InputBorder InputFormfieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(15)),
    borderSide: BorderSide(color: Colors.white, width: 1.0),
  );
  Future<LatLng> getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position);
    curr = LatLng(position.latitude, position.longitude);
    return curr;
  }

  Future loc() async {
    try {
      Response response = await http.post(
          Uri.parse("https://welp-backend-upwk.onrender.com/geocode"),
          headers: {
            'Content-Type': "application/json",
          },
          body: jsonEncode({"input_data": location.text}));
      print(response.statusCode);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        print(jsonData["prediction"]);

        print("Successfull");
        return jsonData["prediction"];
      } else {
        print("nahi hua");
        return [0, 0];
      }
    } catch (e) {
      print(e.toString());
      return [0, 0];
    }
  }

  Future<int> heartbeat() async {
    try {
      Response response = await http.get(
        Uri.parse("https://welp-backend.onrender.com/api/heartrate"),
        headers: {
          'Content-Type': "application/json",
        },
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        print(jsonData["heart_rate"]);

        print("Successfull");
        return jsonData["heart_rate"];
      } else {
        print("nahi hua");
        return 1;
      }
    } catch (e) {
      print(e.toString());
      return 1;
    }
  }
}

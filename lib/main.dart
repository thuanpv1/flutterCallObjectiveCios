import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterplugin/view_multi_camera.dart';

import 'view_single_camera.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isSingle = true;
  String viewType = '<platform-view-type>';
  final Map<String, dynamic> creationParams = <String, dynamic>{
    'serial': '55685723|54110161|55685724|54110162|55687723|55685723'
  };

  static const platform = MethodChannel('samples.flutter.dev/battery');

    Future<void> nextPage() async {
    try {
      await platform.invokeMethod('nextPage', {'index': 4});
    } on PlatformException catch (e) {
      print('the method channel is not implemented');
    }
  }

  void swithView() {
    setState(() {
      isSingle = !isSingle;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   // Here we take the value from the MyHomePage object that was created by
      //   // the App.build method, and use it to set our appbar title.
      //   title: Text(widget.title),
      // ),
      body: Stack(
        children: [
          if (isSingle) SingleCameraView(),
          if (!isSingle) MultiCameraView(),
          Container(width: MediaQuery.of(context).size.width, height: 60, color: Colors.green,
          child: Row(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_back, color: Colors.white,)),
              Center(child: const Text('Camera1', style: TextStyle(color: Colors.white),))
            ],
          ),),
          
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: swithView,
        tooltip: 'Increment',
        child: const Icon(Icons.play_arrow_outlined),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

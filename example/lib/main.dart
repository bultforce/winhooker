import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:winhooker/winhooker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _winHooker = Winhooker();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _winHooker.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        home: HomeScreen()
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late Winhooker _winhooker;
  late String applicationPath;
  final myController = TextEditingController();
  String? _content;
  late StreamSubscription keyBoardStreamSubscription;
  late StreamSubscription mouseStreamSubscription;
  @override
  void initState() {

    super.initState();
    applicationPath = "check directory path";
    _winhooker = Winhooker();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 200,
              child: SingleChildScrollView(
                child: Column(

                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: myController,
                      ),
                    ),


                    /*TextField(
                controller: _textController,
                decoration: const InputDecoration(labelText: 'Enter your name'),
              ),
              ElevatedButton(
                child: const Text('Save to file'),
                onPressed: _writeData,
              ),
              const SizedBox(
                height: 150,
              ),
*/

                    /*const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headline4,
              ),*/

                    Text(_content ?? 'Press the button to load LOGS',
                    ),

                    /*   ElevatedButton(
                child: const Text('Read my name from the file'),
                onPressed: _readData,
              )
*/


                  ],
                ),
              ),
            ),
            MaterialButton(
              padding:const EdgeInsets.symmetric(horizontal: 40),
              color: Colors.blue,
              onPressed: ()async{
                var patha= await getApplicationDocumentsDirectory();
                setState(() {
                  applicationPath = patha.path;
                });
              },
              child:  Text(applicationPath, style: TextStyle(color: Colors.white),),),
            SizedBox(height: 20,),
            MaterialButton(
              padding:const EdgeInsets.symmetric(horizontal: 40),
              color: Colors.blue,
              onPressed: ()async{
                _winhooker.initHooker();
              },
              child: const Text("SetUp Initial Hook", style: TextStyle(color: Colors.white),),),
            SizedBox(height: 20,),
            MaterialButton(
              padding:const EdgeInsets.symmetric(horizontal: 40),
              color: Colors.blue,
              onPressed: ()async{
                _winhooker.keyboardLogger();
              },
              child: const Text("Start Keyboard Logs", style: TextStyle(color: Colors.white),),),
            SizedBox(height: 20,),
            MaterialButton(
              padding:const EdgeInsets.symmetric(horizontal: 40),
              color: Colors.blue,
              onPressed: ()async{
                _winhooker.mouseLogger();
              },
              child: const Text("Start Mouse Logs", style: TextStyle(color: Colors.white),),),
          ],
        ),
      ),
      floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,

          children: [
            FloatingActionButton(
              onPressed: () {
                var location = Directory.current.path;
                location = location.replaceFirst("example", "");
                location = location.replaceFirst("python_scripts", "");


                myController.text = location;
                setState(() {

                });
              },
              tooltip: 'search',
              child: const Icon(Icons.search_sharp),
            ),
            FloatingActionButton(
              onPressed: _readData,
              tooltip: 'logs',
              child: const Icon(Icons.note_add_sharp),
            ),
          ],
        )// This trailing comma makes auto-formatting nicer for build methods.

    );
  }
  Future<void> _readData() async {
    var location = Directory.current.path;
    location = location.replaceFirst("example", "");
    location = location.replaceFirst("python_scripts", "");


    print(location);
    final myFile = File("$location/python_scripts/mouse_log0.txt");
    final data = await myFile.readAsString(encoding: utf8);
    setState(() {
      _content = data;
    });

  }
}


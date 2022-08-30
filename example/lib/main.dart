import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
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
  late StreamSubscription keyBoardStreamSubscription;
  late StreamSubscription mouseStreamSubscription;
  @override
  void initState() {
    super.initState();
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
              height: 50,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  MaterialButton(
                    padding:const EdgeInsets.symmetric(horizontal: 40),
                    color: Colors.blue,
                    onPressed: ()async{
                      keyBoardStreamSubscription = _winhooker.streamKeyboardHook().listen((event) {
                        debugPrint(event);
                      });
                    },
                    child: const Text("Start KeyBoard Hook", style: TextStyle(color: Colors.white),),),
                  MaterialButton(
                    padding:const EdgeInsets.symmetric(horizontal: 40),
                    color: Colors.blue,
                    onPressed: ()async{
                      keyBoardStreamSubscription.cancel();
                    },
                    child: const Text("Stop KeyBoard Hook", style: TextStyle(color: Colors.white),),),
                ],
              ),
            ),
            const SizedBox(height: 10,),
            Container(
              color: Colors.white,
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  MaterialButton(
                    padding:const EdgeInsets.symmetric(horizontal: 40),
                    color: Colors.blue,
                    onPressed: ()async{
                      mouseStreamSubscription = _winhooker.streamMouseHook().listen((event) {
                        debugPrint(event);
                      });
                    },
                    child: const Text("Start Mouse Hook", style: TextStyle(color: Colors.white),),),
                  MaterialButton(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    color: Colors.blue,
                    onPressed: ()async{
                      mouseStreamSubscription.cancel();
                    },
                    child: const Text("Stop Mouse Hook", style: TextStyle(color: Colors.white),),),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


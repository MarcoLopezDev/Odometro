import 'package:flutter/material.dart';
import 'dart:async';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:pedometer/pedometer.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:timer_count_down/timer_controller.dart';

import 'dart:developer' as developer;

String formatDate(DateTime d) {
  return d.toString().substring(0, 19);
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  //-----------------------------------------------------
  //Timer Pocho
  int _counter = 10;
  Timer _timer;

  void _startTimer() {
      _counter = 10;
      if (_timer != null) {
        _timer.cancel();
      }
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          if (_counter > 0) {
            _counter--;
          } else {
            _timer.cancel();
            sendData();
          }
        });
      });
      
    }


  //-----------------------------------------------------
  Stream<StepCount> _stepCountStream;
  Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?', _steps = '?';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void onStepCount(StepCount event) {
    print(event);
    setState(() {
      _steps = event.steps.toString();
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print(event);
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 'Step Count not available';
    });
  }

  void initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }

  Future<String> sendData() async{ //New Function to send emails
    
    var stepsData = jsonEncode(<String, String>{
        "Email": "marcodevlg@gmail.com",
        "Name": "Marco Lopez",
        "Datetime": DateTime.now().toIso8601String(),
        "Step": _steps
    });

    var response = await http.post(
      Uri.https('apiproductorparcial.azurewebsites.net', '/api/data'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: stepsData
    );
    print(response.body);
    return "Success!!";
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Your Odometer'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Steps taken:',
                style: TextStyle(fontSize: 30),
              ),
              Text(
                _steps,
                style: TextStyle(fontSize: 60),
              ),
              Divider(
                height: 100,
                thickness: 0,
                color: Colors.white,
              ),
              Divider(
                height: 50,
                thickness: 0,
                color: Colors.white,
              ),
              Center(
                child: Column(
                  children: <Widget>[
                    new ElevatedButton(
                      onPressed: sendData,
                      child: new Text("Enviar datos")
                    ),
                  ]
                )
              ),
                (_counter > 0)
                ? Text("")
                : Text(
                    "DONE!",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 48,
                    ),
                  ),
            Text(
              '$_counter',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 48,
              ),
            ),
            Center(
                child: Column(
                  children: <Widget>[
                    new ElevatedButton(
                      onPressed: () => _startTimer(),
                      child: Text("Start 10 second count down"),
                    ),
                  ]
                )
              ),


            ],
          ),
        ),
      ),
    );

  }
}
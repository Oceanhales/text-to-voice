import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

String ? _callid;

Future<Call> createCall(String voice, String message, String phone ) async {

  final response = await http.post(
     Uri.parse('http://36.255.69.210/api/otp_call'),
    //https://cors-anywhare.herokuapp.com/
    headers: <String, String>{
      'Content-Type' : 'application/json; charset=UTF-8',
      "App-Name" : "otptestch",
      "App-Key" : "FF9B57BF990167604256833574CA6B5378834A455E76A510671A2564F16116A3",
    },
    body: jsonEncode(<String, String>{

      "voice" : voice,
      "msg" : message,
      "phone" : phone,

    }),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 CREATED response,
    // then parse the JSON.
    print("status 200 ok");
    return Call.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Failed to create call.');
  }
}

class Call {
  final String call_id;
  const Call({required this.call_id});

  factory Call.fromJson(Map<String, dynamic> json) {
    return Call(
      call_id: json['call_id'],
    );
  }
}


// ----------------------------------------------
Future<CallStatus> createCallStatus() async {

  final response = await http.get(
    Uri.parse('http://36.255.69.210/api/call_status/'+_callid!),
    headers: <String, String>{
      'Content-Type' : 'application/json; charset=UTF-8',
      "App-Name" : "otptestch",
      "App-Key" : "FF9B57BF990167604256833574CA6B5378834A455E76A510671A2564F16116A3",
    },
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 CREATED response,
    // then parse the JSON.
    print("status 200 ok");
    return CallStatus.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Failed to get call status');
  }
}

class CallStatus {
  final String message;
  final String phone;
  final String status;
  final String task_id;
  final String tid;
  final String voice;
  const CallStatus({required this.message,required this.phone, required this.status, required this.task_id, required this.tid, required this.voice});

  factory CallStatus.fromJson(Map<String, dynamic> json) {
    return CallStatus(
        message: json['msg'],
        phone: json['phone'],
        status: json['status'],
        task_id: json['task_id'],
        tid: json['tid'],
        voice: json['voice'],
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final TextEditingController messageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String dropdownvalue = 'Bangla Female';
  String dropdownsend = 'banglavoice';
  String ? _phoneerror;
  String ?_messageerror;
  Future<Call> ?_futureCall;
  Future<CallStatus> ?_futureCallStatus;


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Create Call Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(backgroundColor: Colors.white,
          elevation: 0,
          //title: Center(child: const Text('Create Voice Call',style: TextStyle(color: Colors.black),)),
        ),
        body: Container(
          color: Colors.white,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
                (_futureCall == null) ? buildColumn() : buildFutureBuilder(),
              // buildColumn(),
              // buildFutureBuilder(),
              // buildStatusFutureBuilder()
            ],
          )
          //(_futureCall == null) ? buildColumn() : buildFutureBuilder(),
        ),
      ),
    );
  }

  Column buildColumn() {
    final voices = ["Bangla Female","Bangla Male","English Female","English Male"];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        DropdownButton(items: voices.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (String? newValue){
          setState(() {
            dropdownvalue = newValue!;
          });
        },value: dropdownvalue,),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: messageController,
            maxLines: 3,
            decoration: InputDecoration(
                //contentPadding: EdgeInsets.symmetric(vertical: 40.0,horizontal: 8.0),
                hintText: 'Enter message',
                labelText: "Message",
                errorText: _messageerror,
                border: OutlineInputBorder()
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: phoneController,
            decoration: InputDecoration(
                hintText: 'Enter mobile number',
                labelText: "Mobile",
                errorText: _phoneerror,
                border: OutlineInputBorder()
            ),
            keyboardType: TextInputType.phone,

          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 0.0,top: 50),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                if(phoneController.text.length!=11)
                  _phoneerror = "phone number not valid please check again";
                else
                  _phoneerror = null;
              });
              setState(() {
                if(messageController.text.length>120)
                  _messageerror = "message is too long max 120 ";
                if(messageController.text.length<1)
                  _messageerror = "message is empty";
                else
                  _messageerror = null;
              });
              if(_messageerror == null && _phoneerror == null){setState(() {
                if(dropdownvalue=="Bangla Female"){setState(() {
                  dropdownsend = "voice1";
                }); }
                if(dropdownvalue=="Bangla Male"){setState(() {
                  dropdownsend = "voice2";
                });}
                if(dropdownvalue=="English Female"){setState(() {
                  dropdownsend = "voice3";
                });}
                if(dropdownvalue=="English Male"){setState(() {
                  dropdownsend = "voice4";
                });}
                 _futureCall = createCall(dropdownsend,messageController.text,phoneController.text);
                //createCall(dropdownsend,messageController.text,phoneController.text);
              });}

            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: const Text('Create Text to voice Call'),
            ),
          ),
        ),
      ],
    );
  }

  FutureBuilder<Call> buildFutureBuilder() {
    return FutureBuilder<Call>(
      future: _futureCall,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _callid=snapshot.data!.call_id;
          return Column(
            children: [
              Container(child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
                    child: Text("Call Successfully Sent",style: TextStyle(color: Colors.green.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),),
                  ),
                ],
              )),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _futureCallStatus = createCallStatus();
                  });
                },
                child: const Text('press to check this call status'),
              ),
              buildStatusFutureBuilder(),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _futureCall = null;
                    _futureCallStatus = null;
                  });
                },
                child: const Text('Back'),
              ),

            ],
          );
        } else if (snapshot.hasError) {
          return Column(
            children: [
              Text('${snapshot.error}'),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _futureCall = null;
                    _futureCallStatus = null;
                  });
                },
                child: const Text('Back'),
              ),
            ],
          );
        }
        //return const CircularProgressIndicator();
        return Text("");
      },
    );

  }

  //-------------------
  FutureBuilder<CallStatus> buildStatusFutureBuilder() {
    return FutureBuilder<CallStatus>(
      future: _futureCallStatus,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Call Status",style: TextStyle(color: Colors.green.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  alignment: Alignment.center,
                    child: Column(
                  children: [
                    Text("call status is  "+ snapshot.data!.status),
                  ],
                )),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Phone number is          : "+ snapshot.data!.phone),
                        Text("The voice Message Is  : "+ snapshot.data!.message),
                      ],
                    )),
              ),
            ],
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}

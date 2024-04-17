 
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:log_in/OCPP/chargePoint.dart'; 
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_client/web_socket_client.dart'; 
final firebaseApp = Firebase.app();
final rtdb = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://my-project-1579067571295-default-rtdb.firebaseio.com/');


final ref = FirebaseDatabase.instance.ref();

final socket = WebSocket(Uri.parse('ws://172.20.32.55:9000/pj5'),
    timeout: Duration(seconds: 30));

 class ChargePointHome extends StatefulWidget {
  @override
  _ChargePointHome createState() => _ChargePointHome();
}

class _ChargePointHome extends State<ChargePointHome> {
 String userEmail="";
 List<List<String>> tableData = [
 ['chargingPointVendor', 'chargingPointModel', 'Status', 'EnergyUsed'],
  ];
  
  void initState() { 
    super.initState(); 
     addTo();
  readData();  
  } 
  
  bool isLoading = true; 
 
  Future<void> readData() async { 
      
    // Please replace the Database URL 
    // which we will get in “Add Realtime Database”  
    // step with DatabaseURL 
      
    var url = "https://my-project-1579067571295-default-rtdb.firebaseio.com/"+"chargePoint.json"; 
   
    try { 
      final response = await http.get(Uri.parse(url)); 
      final extractedData = json.decode(response.body) as Map<String, dynamic>; 
      if (extractedData == null) { 
        return; 
      } 
      extractedData.forEach((key, value) { 
       tableData.add([value['chargingPointVendor'].toString(),value['chargingPointModel'].toString(),value['status'],'0']);
      }); 
      setState(() { 
        isLoading = false; 
      }); 
    } catch (error) { 
      throw error;
    } 
  } 

 


   addTo()async{
   
            // final ref = FirebaseDatabase.instance.ref();
//     final vendorname = await ref.child('chargePoint/pj1/chargingPointVendor').get();
// final modelname = await ref.child('chargePoint/pj1/chargingPointModel').get();


//   ref.onValue.listen((event) {
//   for (final child in event.snapshot.children) {
//      final vendorname =  child.child('chargingVendor');
// final modelname = child.child('chargingPoint/chargingPointModel');
// tableData.add([  vendorname.value.toString() ,modelname.value.toString(), 'Unavailable', '0 kWh']);
//   }
// }, onError: (error) {
//  print('error');
// });

//  print('hii');
//             tableData.add([  vendorname.value.toString() ,modelname.value.toString(), 'Unavailable', '0 kWh']);
          

  var url = "https://my-project-1579067571295-default-rtdb.firebaseio.com/"+"user.json"; 
   
   final user =  await FirebaseAuth.instance.currentUser;
         userEmail="${user?.email}";
    try { 
      final response = await http.get(Uri.parse(url)); 
      final extractedData = json.decode(response.body) as Map<String, dynamic>; 
      if (extractedData == null) { 
        return; 
      } 
      extractedData.forEach((key, value) { 
        
        if(value['email']== userEmail){
          print(userEmail);
        }
      }); 
      setState(() { 
        isLoading = false; 
      }); 
    } catch (error) { 
      throw error;
    } 
  } 

 
@override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Charge Points Nearby'),
        ),
       body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: List.generate(
              4,
              (index) => DataColumn(
                label: TextButton( child:Text(tableData[0][index]),onPressed: () {
                  
                }, ),
              ),
            ),
            rows: List.generate(
              tableData.length - 1,
              (rowIndex) => DataRow(
                cells: List.generate(
                  tableData[rowIndex + 1].length,
                  (cellIndex) => DataCell(
                    TextButton(onPressed:(){
             
              socket.send('[2, "12345", "Authorize", { "idTag":"${userEmail}"   }]');
              socket.messages.listen((message) async{
               
           showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
          
            title: Text("recieving message.."),
            actions: [
              Container(
                // color: const Color.fromARGB(255, 255, 21, 21),
                child:
                         TextButton(
                
                 child: Text( (message.toString().contains('Accepted') ? 'Accepted' : 'Rejected') +" Now connect to plugd" ),
                 onPressed:  () {
                  
                  }
                   
              ),
              ),
            ],
          );
        }  );
              }
              );


                    } ,child: Text(tableData[rowIndex + 1][cellIndex]),),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           
             Navigator.pushNamed(context, 'chargePoint');
           },
        child: Icon(Icons.dangerous),
      ),
      
    );
  }
}
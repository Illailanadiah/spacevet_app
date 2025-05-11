import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spacevet_app/authentication/login.dart';
import 'package:spacevet_app/homescreen.dart'; 

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    
      return Scaffold( 
      body: StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context,snapshot){
        if(snapshot.hasData){
          return HomeScreen();
        }
        else{
          return Login();
        }
      }),
    );
  }
  }
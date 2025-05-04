import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spacevet_app/wrapper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;

  signout() async {
    await FirebaseAuth.instance.signOut();
    // Optionally, you can navigate to the login screen after signing out
    Get.offAll(Wrapper());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      transform: Matrix4.translationValues(xOffset, yOffset, 0)
        ..scale(isDraweOpen ? 0.8 : 1)
        ..rotateZ(isDraweOpen ? -0.5 : 0),
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: 
        isDraweOpen ? BorderRadius.circular(40): BorderRadius.circular(0),
      ),
      child: SingleChildScrollView(
        child: Column( 
          children: [ 
            <Widget> [
              SizedBox( 
                height: 50,
              ),
              Container( 
                margin: EdgeInsets.symmetric( 
                  horizontal: 20
                ),
                child: Row( 
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[ 
                    isdrawerOpen ? 
                    GestureDetector( 
                      child: Icon(Icons.arrow_back_ios_new_rounded), 
                      onTap: (() { 
                        setState(() { 
                          isDraweOpen = false;
                          xOffset = 0;
                          yOffset = 0;
                        });
                      },
                    )
                    : GestureDetector( 
                      child: Icon(Icons.menu), 
                      onTap: () { 
                        setState(() { 
                          isDraweOpen = true;
                          xOffset = 290;
                          yOffset = 80;
                        });
                      },
                    ),
                    Text(
                      'Beautiful Drawer',
                      style: TextStyle( 
                        fontSize: 20,
                        color: Colors.black,
                        decoration: TextDecoration.none),
                    ),
                    Container(),
                  ],
                ),
                ),
                SizedBox(
                  height: 20,
                ),
      
      
      
        /*child: Center(
          child: Text('Hello \n ${user!.email}'),
        ),*/
      ),
    );
    /*floatingActionButton: FloatingActionButton(
        onPressed: (() => signout()),
        child: const Icon(Icons.login_rounded),
      ),*/
  }
}
      


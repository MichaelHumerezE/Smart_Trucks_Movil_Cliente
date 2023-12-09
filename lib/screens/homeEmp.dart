import 'package:smart_trucks_v2/services/user_service.dart';
import 'package:flutter/material.dart';

import 'login.dart';

class HomeEmp extends StatefulWidget {
  @override
  _HomeEmpState createState() => _HomeEmpState();
}

class _HomeEmpState extends State<HomeEmp> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart-Trucks-Empleados'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: (){
              logout().then((value) => {
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Login()), (route) => false)
              });
            },
          )
        ],
      ),
      /*
      body: currentIndex == 0 ? PostScreen() : Profile(),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
           Navigator.of(context).push(MaterialPageRoute(builder: (context)=>PostForm(
             title: 'Add new post',
           )));
        },
        child: Icon(Icons.add),
      ),*/
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        notchMargin: 5,
        elevation: 10,
        clipBehavior: Clip.antiAlias,
        shape: CircularNotchedRectangle(),
        child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: ''
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: ''
            )
          ],
          currentIndex: currentIndex,
          onTap: (val) {
            setState(() {
              currentIndex = val;
            });
          },
        ),
      ),
    );
  }
}
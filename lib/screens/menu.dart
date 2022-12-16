import 'dart:async';
import 'package:flutter/material.dart';
import 'package:test/components/menu_list2.dart';
import 'package:test/screens/checkup_header.dart';
import 'package:test/screens/checkup_itembulkhead.dart';
import 'package:test/screens/container_pickup.dart';
import 'package:test/screens/menu_container.dart';
import 'package:test/screens/menu_transport.dart';

class Menu extends StatefulWidget {
  static String routeName = "/menu";
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<Menu> {
  bool containerVisible = true;
  bool transportationVisible = true;
  bool checkupVisible = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
            image: new DecorationImage(
          image: new AssetImage("assets/hmc_background6.jpeg"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.5), BlendMode.dstATop),
        )),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 50),
          child: Column(
            children: [
              SizedBox(height: 10),
              Visibility(
                visible: containerVisible,
                child: MenuList2(
                  text: "Container",
                  imageIcon: ImageIcon(
                    AssetImage('assets/container.png'),
                    size: 45,
                    color: Colors.blue,
                  ),
                  press: () => {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MenuContainer()))
                  },
                ),
              ),
              Visibility(
                visible: transportationVisible,
                child: MenuList2(
                  text: "Transportation",
                  imageIcon: ImageIcon(
                    AssetImage('assets/transportation.png'),
                    size: 45,
                    color: Colors.blue,
                  ),
                  press: () => {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MenuTransport()))
                  },
                ),
              ),
              Visibility(
                visible: checkupVisible,
                child: MenuList2(
                  text: "Check-up",
                  imageIcon: ImageIcon(
                    AssetImage('assets/checkup.png'),
                    size: 45,
                    color: Colors.blue,
                  ),
                  press: () => {
                    /* Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CheckupHeader()))*/
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

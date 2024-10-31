import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:parkify/Components/info_container.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text(
            "HUDUMA PARK",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              SizedBox(height: 16),
              InfoContainer(
                icon: Icon(
                  FontAwesomeIcons.car,
                  size: 30,
                  color: Color.fromARGB(255, 255, 106, 67),
                ),
                amount: 10,
                label: "Vehicles Parked",
              ),
              SizedBox(height: 16),
              InfoContainer(
                amount: 0,
                label: "Empty Parking Slots",
                icon: Icon(
                  FontAwesomeIcons.squareParking,
                  size: 30,
                  color: Color.fromARGB(255, 255, 106, 67),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: const CircleBorder(),
          child: const Icon(
            FontAwesomeIcons.plus,
          ),
        ),
      ),
    );
  }
}

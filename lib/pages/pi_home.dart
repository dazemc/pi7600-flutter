import 'package:flutter/material.dart';
import 'package:pi7600_flutter/pages/sms_home.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              spacing: 10.0,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => SMSHome()));
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.blueGrey)),
                    child: Icon(Icons.sms, size: 50)),
                TextButton(
                    onPressed: () {},
                    style: ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.blueGrey)),
                    child: Icon(Icons.phone, size: 50))
              ],
            ),
            Column(
              spacing: 10.0,
              children: [
                TextButton(
                    onPressed: () {},
                    style: ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.blueGrey)),
                    child: Icon(Icons.gps_fixed, size: 50)),
                TextButton(
                    onPressed: () {},
                    style: ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.blueGrey)),
                    child: Icon(Icons.wifi, size: 50)),
              ],
            ),
            Column(
              spacing: 10.0,
              children: [
                TextButton(
                    onPressed: () {},
                    style: ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.blueGrey)),
                    child: Icon(Icons.camera, size: 50)),
                TextButton(
                    onPressed: () {},
                    style: ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.blueGrey)),
                    child: Icon(Icons.settings, size: 50)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

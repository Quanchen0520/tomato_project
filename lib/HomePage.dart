import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(//Row
          children: [
            SizedBox(height: 100),
            Text(
              "Work time",
              style: TextStyle(fontSize: 50),
            ),
            SizedBox(height: 300),
            ElevatedButton(
                onPressed: () {},
                child: Text("Log in ")
            ),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {},
                child: Text("Register")
            ),
            // ElevatedButton(
            //     onPressed: () {
            //       print("已被點擊");
            //     },
            //     child: Text("3jifrwgerhgvw")),
            // Image.asset('assets/Tomato250-1.jpg',height: 200,),
          ],
        )
      ),
    );
  }
}

import 'package:flutter/material.dart';

class LoaderComponent extends StatefulWidget {
  const LoaderComponent({super.key});

  @override
  State<LoaderComponent> createState() => _LoaderComponentState();
}

class _LoaderComponentState extends State<LoaderComponent> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          alignment: Alignment.center,
          color: Colors.black.withOpacity(0.3),
          child: Image.asset(
           'assets/loader.gif',
            height: 50,
            width: 50,
          ),
        ),
      ],
    );
  }
}

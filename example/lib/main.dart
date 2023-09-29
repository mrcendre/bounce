import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:motion/motion.dart';

import 'card.dart';

const cardBorderRadius = BorderRadius.all(Radius.circular(20));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize the Motion plugin.
  await Motion.instance.initialize();

  /// ... and run the sample app.
  runApp(const BounceDemoApp());
}

class BounceDemoApp extends StatelessWidget {
  const BounceDemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const MaterialApp(
        title: 'Bounce Demo',
        debugShowCheckedModeBanner: false,
        home: BounceDemoPage(),
      );
}

class BounceDemoPage extends StatefulWidget {
  const BounceDemoPage({Key? key}) : super(key: key);

  @override
  State<BounceDemoPage> createState() => _BounceDemoPageState();
}

class _BounceDemoPageState extends State<BounceDemoPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
          body: Stack(children: [
        Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Text(
                'Bounce example',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800, color: const Color.fromARGB(255, 0, 0, 0)),
              )),
          const Card(width: 280, height: 150, borderRadius: cardBorderRadius),
          Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 35),
              child: Text(
                'without Bounce',
                style: Theme.of(context).textTheme.bodyLarge,
              )),
          const SizedBox(width: 70),
          const Bounce(
            child: Motion(
                borderRadius: cardBorderRadius,
                shadow: ShadowConfiguration(blurRadius: 20, topOffset: 15),
                child: Card(
                  width: 280,
                  height: 150,
                  borderRadius: cardBorderRadius,
                )),
          ),
          Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 35),
              child: Text(
                'with Bounce + Motion',
                style: Theme.of(context).textTheme.bodyLarge,
              )),
        ]))
      ]));
}

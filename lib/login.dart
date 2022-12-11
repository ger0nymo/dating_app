import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: null,
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Image.asset('images/1.png', height: 250, width: 250),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Welcome to the app',
                  style: GoogleFonts.nunitoSans(
                      fontSize: 36, fontWeight: FontWeight.w700),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Please sign in to continue',
                  style: GoogleFonts.nunitoSans(fontSize: 20),
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Container(
                  width: 200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.person),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text('Sign in with Google'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

import 'package:code_learn/app_constants/button.dart';
import 'package:code_learn/app_constants/colors.dart';
import 'package:code_learn/app_constants/textfield.dart';
import 'package:code_learn/utils/customtextformfiled.dart';
import 'package:code_learn/view/navigPage.dart';
import 'package:code_learn/view/registerPage.dart';
import 'package:flutter/material.dart';

import '../utils/app_text.dart';
import '../utils/app_text_style.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
   _emailController.dispose();
   _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.champagnePink,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppText(
                        text: "Hello there!",
                        style:  AppTextStyle.headline1,

                      ),
                      const SizedBox(height: 30),
                     CustomTextFormField(controller: _emailController, hintText: "Username/Email")

                     , const SizedBox(height: 20),
                     CustomTextFormField(controller: _passwordController, hintText: "Password",obscureText: true,)
                     , const SizedBox(height: 30),
                      Button(
                        text: "Sign In",
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Navigpage()),
                                  (route) => false,
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account",
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Registerpage()),
                              );
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

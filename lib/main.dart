import 'package:code_learn/view/loginPage.dart';
import 'package:code_learn/view_model/auth_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main(){
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
         ChangeNotifierProvider(create: (context) => AuthViewModel(),)
      ],
      child: MaterialApp(
        home:Loginpage() ,debugShowCheckedModeBanner: false,
      ),
    );
  }
}

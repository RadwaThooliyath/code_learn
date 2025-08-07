import 'package:code_learn/view/loginPage.dart';
import 'package:code_learn/view/navigPage.dart';
import 'package:code_learn/view/splash_screen.dart';
import 'package:code_learn/view_model/auth_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
      ],
      child: MaterialApp(
        title: 'Code Learn',
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthViewModel>(context, listen: false).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        // Show splash screen while checking authentication status
        if (!authViewModel.isInitialized) {
          return const SplashScreen();
        }
        
        // Navigate based on authentication status
        if (authViewModel.isAuthenticated) {
          return const Navigpage();
        } else {
          return const Loginpage();
        }
      },
    );
  }
}

import 'package:uptrail/view/loginPage.dart';
import 'package:uptrail/view/navigPage.dart';
import 'package:uptrail/view/splash_screen.dart';
import 'package:uptrail/view_model/auth_viewModel.dart';
import 'package:uptrail/view_model/course_viewmodel.dart';
import 'package:uptrail/services/security_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize security service to prevent screenshots and screen recording
  await SecurityService.instance.initializeSecurity();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
        ChangeNotifierProvider(create: (context) => CourseViewModel()),
      ],
      child: MaterialApp(
        title: 'Uptrail',
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
          return const LoginPage();
        }
      },
    );
  }
}

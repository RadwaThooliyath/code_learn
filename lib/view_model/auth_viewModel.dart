import 'package:code_learn/model/user_model.dart';
import 'package:code_learn/services/auth_service.dart';
import 'package:flutter/cupertino.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String _error = "";

  User? get user => _user;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isAuthenticated => _user != null;

  void _setLoading(bool loading){
    _isLoading=loading;
    notifyListeners();
  }
  void _setError(String error){
    _error =error;
    notifyListeners();
  }
  void _setUser(User? user){
    _user=user;
    notifyListeners();
  }

  Future<void> login(String email,String password) async{
    _setLoading(true);
    _setError("");
    try{
      final loggedInUser = await _authService.login(email, password);
      if(loggedInUser != null){
        _setUser(loggedInUser);
      }else{
        _setError("Inavalid credential or failed to login");
      }
    }catch(e){
      _setError("Login failed : $e");
    }finally{
      _setLoading(false);
    }
  }
  Future<void> register(String name,String email,String password) async{
    _setLoading(true);
    _setError("");
    try{
      final registeredUser = await _authService.register(name, email, password);
      if(registeredUser != null){
        _setUser(registeredUser);
      }else{
        _setError("Registration failed");
      }
    }catch(e){
      _setError("Registration failed : $e");
    }finally{
      _setLoading(false);
    }
  }
}

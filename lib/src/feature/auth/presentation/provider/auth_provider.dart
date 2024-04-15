import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/data/usecase/usecase.dart';
import '../../business/param/login_params.dart';
import '../../business/param/verify_otp_param.dart';
import '../../business/usecase/auth_get_user_usecase.dart';
import '../../business/usecase/auth_is_looged_in_usecase.dart';
import '../../business/usecase/auth_logout_usecase.dart';
import '../../business/usecase/auth_on_auth_change_usecase.dart';
import '../../business/usecase/send_otp_usecase.dart';
import '../../business/usecase/update_user_data.dart';
import '../../business/usecase/verify_otp_usecase.dart';
import '../../data/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthSendOtpUseCase authSendOtpUseCase;
  final AuthLogoutUseCase authLogoutUseCase;
  final AuthGetUserUseCase authGetUserUseCase;
  final AuthIsLoggedInUseCase authIsLoggedInUseCase;
  final AuthOnAuthOnAuthChangeUseCase authOnAuthChangeUseCase;
  final AuthVerifyOtpUseCase authVerifyOtpUseCase;
  final AuthUpdateUserDataUseCase authUpdateUserDataUseCase;

  AuthProvider({
    required this.authSendOtpUseCase,
    required this.authLogoutUseCase,
    required this.authGetUserUseCase,
    required this.authIsLoggedInUseCase,
    required this.authOnAuthChangeUseCase,
    required this.authVerifyOtpUseCase,
    required this.authUpdateUserDataUseCase,
  });

  bool checkIsLoggedIn() {
    return authIsLoggedInUseCase.call(NoParams());
  }

  User? getUser() {
    return authGetUserUseCase.call(NoParams());
  }

  Future<void> logout() async {
    await authLogoutUseCase.call(NoParams());
  }

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String _loginErrorMessage = '';

  String get loginErrorMessage => _loginErrorMessage;

  CurrentUserModel? _currentUser;
  CurrentUserModel? get currentUser => _currentUser;

  void setUserInfo(CurrentUserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void getUserModel() {
    final user = getUser();
    if (user != null) {
      setUserInfo(CurrentUserModel(
        firstName: user.userMetadata?['fName'] ?? '',
        lastName: user.userMetadata?['lName'] ?? '',
      ));
    }
  }

  Future<bool> sendOtp(String phone) async {
    _isLoading = true;
    _loginErrorMessage = '';
    bool isSuccess = false;
    notifyListeners();
    final result = await authSendOtpUseCase.call(LoginParams(phone: phone));

    await result.fold((l) async {
      _loginErrorMessage = l.errorMessage;
      isSuccess = false;
    }, (r) async {
      isSuccess = true;
    });

    _isLoading = false;
    notifyListeners();
    return isSuccess;
  }

  Future<bool> verifyOtp(String token, String phone) async {
    _isLoading = true;
    _loginErrorMessage = '';
    bool isSuccess = false;
    notifyListeners();
    final result = await authVerifyOtpUseCase
        .call(VerifyOtpParam(token: token, phone: phone));

    await result.fold((l) async {
      _loginErrorMessage = l.errorMessage;
      isSuccess = false;
    }, (r) async {
      isSuccess = true;
    });

    _isLoading = false;
    notifyListeners();
    return isSuccess;
  }

  Stream<AuthState> onAuthStateChange() {
    return authOnAuthChangeUseCase.call(NoParams());
  }

  Future<bool> updateUserData(Map<String, dynamic> data) async {
    bool isSuccess = false;
    final result = await authUpdateUserDataUseCase.call(data);

    await result.fold((l) async {
      print('error updating user data');
      print(l.errorMessage);
      isSuccess = false;
    }, (r) async {
      isSuccess = true;
    });

    return isSuccess;
  }
}

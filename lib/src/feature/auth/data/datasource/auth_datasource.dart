import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/data/exception/failure.dart';
import '../../../../core/data/usecase/usecase.dart';
import '../../business/param/login_params.dart';
import '../../business/param/verify_otp_param.dart';

class AuthDataSource {
  final _auth = Supabase.instance.client.auth;

  // method to login user
  Future<Either<AuthFailure, bool>> sendOtp(LoginParams params) async {
    try {
      await _auth.signInWithOtp(phone: params.phone, shouldCreateUser: false);
      return Right(true);
    } on AuthException catch (e) {
      print(e.message);
      return Left(AuthFailure(errorMessage: e.message));
    } catch (e) {
      print(e);
      return Left(AuthFailure(errorMessage: 'Invalid Credential'));
    }
  }

  Future<Either<AuthFailure, bool>> verifyOtp(VerifyOtpParam params) async {
    try {
      await _auth.verifyOTP(
        type: OtpType.sms,
        token: params.token,
        phone: params.phone,
      );

      return Right(true);
    } on AuthException catch (e) {
      print(e.message);
      return Left(AuthFailure(errorMessage: e.message));
    } catch (e) {
      print(e);
      return Left(AuthFailure(errorMessage: 'Invalid Credential'));
    }
  }

  // method to logout user
  Future<Either<AuthFailure, String>> logout(NoParams param) async {
    try {
      await _auth.signOut();
      return const Right('Logged out');
    } catch (e) {
      return Left(AuthFailure(errorMessage: 'Error logging out'));
    }
  }

  // method to check if user is logged in
  bool isLoggedIn(NoParams param) {
    print('is logged in');
    print(_auth.currentUser);
    print('-' * 100);
    return _auth.currentUser != null;
  }

  // method to get user
  User? getUser(NoParams param) {
    return _auth.currentUser;
  }

  // method to updat raw user data
  Future<Either<AuthFailure, bool>> updateUserData(
      Map<String, dynamic> data) async {
    try {
      await _auth.updateUser(UserAttributes(
        data: data,
      ));
      return Right(true);
    } on AuthException catch (e) {
      print(e.message);
      return Left(AuthFailure(errorMessage: e.message));
    } catch (e) {
      print(e);
      return Left(AuthFailure(errorMessage: 'Error updating user data'));
    }
  }

  Stream<AuthState> onAuthStateChange() {
    return _auth.onAuthStateChange;
  }
}

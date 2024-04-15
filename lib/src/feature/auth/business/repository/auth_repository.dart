import 'package:customer_app/src/feature/auth/business/param/verify_otp_param.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/data/exception/failure.dart';
import '../../../../core/data/usecase/usecase.dart';
import '../param/login_params.dart';

abstract class AuthRepository {
  Future<Either<AuthFailure, bool>> sendOtp(LoginParams params);
  Future<Either<AuthFailure, bool>> verifyOtp(VerifyOtpParam params);

  Future<Either<AuthFailure, String>> logout(NoParams param);

  bool isLoggedIn(NoParams param);

  User? getUser(NoParams param);

  Stream<AuthState> onAuthStateChange(NoParams param);
  Future<Either<AuthFailure, bool>> updateUserData(Map<String, dynamic> data);

/*bool isLoggedIn();
  String getUserToken();*/
}

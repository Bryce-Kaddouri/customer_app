import 'package:customer_app/src/feature/auth/business/param/verify_otp_param.dart';
import 'package:dartz/dartz.dart';
import 'package:gotrue/src/types/auth_state.dart';
import 'package:gotrue/src/types/user.dart';

import '../../../../core/data/exception/failure.dart';
import '../../../../core/data/usecase/usecase.dart';
import '../../business/param/login_params.dart';
import '../../business/repository/auth_repository.dart';
import '../datasource/auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl({required this.dataSource});

  @override
  Future<Either<AuthFailure, bool>> sendOtp(LoginParams params) async {
    return await dataSource.sendOtp(params);
  }

  @override
  Future<Either<AuthFailure, bool>> verifyOtp(VerifyOtpParam params) async {
    return await dataSource.verifyOtp(params);
  }

  @override
  User? getUser(NoParams param) {
    return dataSource.getUser(param);
  }

  @override
  bool isLoggedIn(NoParams param) {
    return dataSource.isLoggedIn(param);
  }

  @override
  Future<Either<AuthFailure, String>> logout(NoParams param) async {
    return await dataSource.logout(param);
  }

  @override
  Stream<AuthState> onAuthStateChange(NoParams param) {
    return dataSource.onAuthStateChange();
  }

  @override
  Future<Either<AuthFailure, bool>> updateUserData(
      Map<String, dynamic> data) async {
    return await dataSource.updateUserData(data);
  }
}

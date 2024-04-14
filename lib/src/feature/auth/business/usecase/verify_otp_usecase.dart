import 'package:customer_app/src/feature/auth/business/param/verify_otp_param.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/data/exception/failure.dart';
import '../../../../core/data/usecase/usecase.dart';
import '../repository/auth_repository.dart';

class AuthVerifyOtpUseCase implements UseCase<bool, VerifyOtpParam> {
  final AuthRepository authRepository;

  const AuthVerifyOtpUseCase({
    required this.authRepository,
  });

  @override
  Future<Either<AuthFailure, bool>> call(VerifyOtpParam params) {
    return authRepository.verifyOtp(params);
  }
}

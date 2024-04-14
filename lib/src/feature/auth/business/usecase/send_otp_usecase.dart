import 'package:dartz/dartz.dart';

import '../../../../core/data/exception/failure.dart';
import '../../../../core/data/usecase/usecase.dart';
import '../param/login_params.dart';
import '../repository/auth_repository.dart';

class AuthSendOtpUseCase implements UseCase<bool, LoginParams> {
  final AuthRepository authRepository;

  const AuthSendOtpUseCase({
    required this.authRepository,
  });

  @override
  Future<Either<AuthFailure, bool>> call(LoginParams params) {
    return authRepository.sendOtp(params);
  }
}

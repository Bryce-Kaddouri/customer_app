import 'package:dartz/dartz.dart';

import '../../../../core/data/exception/failure.dart';
import '../../../../core/data/usecase/usecase.dart';
import '../repository/auth_repository.dart';

class AuthLogoutUseCase implements UseCase<String, NoParams> {
  final AuthRepository authRepository;

  const AuthLogoutUseCase({
    required this.authRepository,
  });

  @override
  Future<Either<AuthFailure, String>> call(NoParams param) {
    return authRepository.logout(param);
  }
}

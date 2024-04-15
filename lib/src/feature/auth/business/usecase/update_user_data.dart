import 'package:dartz/dartz.dart';

import '../../../../core/data/exception/failure.dart';
import '../../../../core/data/usecase/usecase.dart';
import '../repository/auth_repository.dart';

class AuthUpdateUserDataUseCase implements UseCase<bool, Map<String, dynamic>> {
  final AuthRepository authRepository;

  const AuthUpdateUserDataUseCase({
    required this.authRepository,
  });

  @override
  Future<Either<AuthFailure, bool>> call(Map<String, dynamic> params) {
    return authRepository.updateUserData(params);
  }
}

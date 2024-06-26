import '../../../../core/data/usecase/usecase.dart';
import '../repository/auth_repository.dart';

class AuthIsLoggedInUseCase implements SingleUseCase<bool, NoParams> {
  final AuthRepository authRepository;

  const AuthIsLoggedInUseCase({
    required this.authRepository,
  });

  @override
  bool call(NoParams params) {
    return authRepository.isLoggedIn(params);
  }
}

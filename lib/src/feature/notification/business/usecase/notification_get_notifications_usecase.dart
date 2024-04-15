import 'package:customer_app/src/feature/notification/business/repository/notification_repository.dart';
import 'package:customer_app/src/feature/notification/data/model/notification_model.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/data/exception/failure.dart';
import '../../../../core/data/usecase/usecase.dart';

class NotificationGetNotificationsUseCase implements UseCase<List<NotificationModel>, NoParams> {
  final NotificationRepository notificationRepository;

  const NotificationGetNotificationsUseCase({
    required this.notificationRepository,
  });

  @override
  Future<Either<DatabaseFailure, List<NotificationModel>>> call(NoParams params) {
    return notificationRepository.getNotifications(params);
  }
}

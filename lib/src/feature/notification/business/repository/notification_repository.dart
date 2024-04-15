import 'package:customer_app/src/core/data/usecase/usecase.dart';
import 'package:customer_app/src/feature/notification/data/model/notification_model.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/data/exception/failure.dart';

abstract class NotificationRepository {
  Future<Either<DatabaseFailure, List<NotificationModel>>> getNotifications(NoParams params);
}

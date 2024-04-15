import 'package:customer_app/src/core/data/usecase/usecase.dart';
import 'package:customer_app/src/feature/notification/data/datasource/notification_datasource.dart';
import 'package:customer_app/src/feature/notification/data/model/notification_model.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/data/exception/failure.dart';
import '../../business/repository/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationDataSource dataSource;

  NotificationRepositoryImpl({required this.dataSource});

  @override
  Future<Either<DatabaseFailure, List<NotificationModel>>> getNotifications(NoParams params) async {
    return await dataSource.getNotifications(params);
  }

  /*@override
  Future<Either<DatabaseFailure, CustomerModel>> getCustomerById(int id) async {
    return await dataSource.getCustomerById(id);
  }*/
}

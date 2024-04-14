import 'package:customer_app/src/core/data/usecase/usecase.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/data/exception/failure.dart';
import '../../business/param/get_order_by_id_param.dart';
import '../../business/repository/order_repository.dart';
import '../datasource/order_datasource.dart';
import '../model/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderDataSource orderDataSource;

  OrderRepositoryImpl({
    required this.orderDataSource,
  });

  @override
  Future<Either<DatabaseFailure, OrderModel>> getOrderById(
      GetOrderByIdParam param) async {
    return await orderDataSource.getOrderById(param.orderId, param.date);
  }

  @override
  Future<Either<DatabaseFailure, List<OrderModel>>> getOrdersByCustomerId(
      NoParams params) async {
    return await orderDataSource.getOrdersByCustomerId(params);
  }
}

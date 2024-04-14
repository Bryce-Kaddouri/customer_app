import 'package:dartz/dartz.dart';

import '../../../../core/data/exception/failure.dart';
import '../../../../core/data/usecase/usecase.dart';
import '../../data/model/order_model.dart';
import '../param/get_order_by_id_param.dart';

abstract class OrderRepository {
  Future<Either<DatabaseFailure, List<OrderModel>>> getOrdersByCustomerId(
      NoParams param);

  Future<Either<DatabaseFailure, OrderModel>> getOrderById(
      GetOrderByIdParam param);
}

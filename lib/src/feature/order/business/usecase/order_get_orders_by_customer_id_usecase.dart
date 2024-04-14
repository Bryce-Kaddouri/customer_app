import 'package:dartz/dartz.dart';

import '../../../../core/data/exception/failure.dart';
import '../../../../core/data/usecase/usecase.dart';
import '../../data/model/order_model.dart';
import '../repository/order_repository.dart';

class OrderGetOrdersByCustomerIdUseCase
    implements UseCase<List<OrderModel>, NoParams> {
  final OrderRepository orderRepository;

  const OrderGetOrdersByCustomerIdUseCase({
    required this.orderRepository,
  });

  @override
  Future<Either<DatabaseFailure, List<OrderModel>>> call(NoParams param) {
    return orderRepository.getOrdersByCustomerId(param);
  }
}

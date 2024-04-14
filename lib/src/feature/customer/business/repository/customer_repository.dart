import 'package:dartz/dartz.dart';

import '../../../../core/data/exception/failure.dart';
import '../../data/model/customer_model.dart';

abstract class CustomerRepository {
  Future<Either<DatabaseFailure, CustomerModel>> getCustomerById(int id);
}

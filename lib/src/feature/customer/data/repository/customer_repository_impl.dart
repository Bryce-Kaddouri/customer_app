import 'package:dartz/dartz.dart';

import '../../../../core/data/exception/failure.dart';
import '../../business/repository/customer_repository.dart';
import '../datasource/customer_datasource.dart';
import '../model/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerDataSource dataSource;

  CustomerRepositoryImpl({required this.dataSource});

  @override
  Future<Either<DatabaseFailure, CustomerModel>> getCustomerById(int id) async {
    return await dataSource.getCustomerById(id);
  }
}

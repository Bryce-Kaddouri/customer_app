import 'package:dartz/dartz.dart';

import '../../../../core/data/exception/failure.dart';
import '../../business/repository/product_repository.dart';
import '../datasource/product_datasource.dart';
import '../model/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductDataSource dataSource;

  ProductRepositoryImpl({required this.dataSource});

  @override
  Future<Either<DatabaseFailure, ProductModel>> getProductById(int id) async {
    return await dataSource.getProductById(id);
  }
}

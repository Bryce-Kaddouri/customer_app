import 'package:dartz/dartz.dart';

import '../../../../core/data/exception/failure.dart';
import '../../../../core/data/usecase/usecase.dart';
import '../../data/model/product_model.dart';
import '../repository/product_repository.dart';

class ProductGetProductByIdUseCase implements UseCase<ProductModel, int> {
  final ProductRepository productRepository;

  const ProductGetProductByIdUseCase({
    required this.productRepository,
  });

  @override
  Future<Either<DatabaseFailure, ProductModel>> call(int id) {
    return productRepository.getProductById(id);
  }
}

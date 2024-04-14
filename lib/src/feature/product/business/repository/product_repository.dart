/*
import 'package:admin_dashboard/src/feature/category/business/param/category_add_param.dart';
*/
import 'package:dartz/dartz.dart';

import '../../../../core/data/exception/failure.dart';
import '../../data/model/product_model.dart';
/*
import '../../data/model/category_model.dart';
*/

abstract class ProductRepository {
  Future<Either<DatabaseFailure, ProductModel>> getProductById(int id);
}

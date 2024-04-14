import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/data/exception/failure.dart';
import '../model/product_model.dart';

class ProductDataSource {
  final _client = Supabase.instance.client;

  Future<Either<DatabaseFailure, ProductModel>> getProductById(int id) async {
    try {
      List<Map<String, dynamic>> response = await _client
          .from('products')
          .select()
          .eq('id', id)
          .limit(1)
          .order('id', ascending: true);
      if (response.isNotEmpty) {
        ProductModel productModel = ProductModel.fromJson(response[0]);
        return Right(productModel);
      } else {
        return Left(DatabaseFailure(errorMessage: 'Error getting product'));
      }
    } catch (e) {
      return Left(DatabaseFailure(errorMessage: 'Error getting product'));
    }
  }
}

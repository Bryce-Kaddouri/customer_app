import 'package:flutter/material.dart';

import '../../business/usecase/product_get_product_by_id_usecase.dart';
import '../../data/model/product_model.dart';

class ProductProvider with ChangeNotifier {
  final ProductGetProductByIdUseCase productGetProductByIdUseCase;

  ProductProvider({
    required this.productGetProductByIdUseCase,
  });

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _searchText = '';

  String get searchText => _searchText;

  void setSearchText(String value) {
    _searchText = value;
    notifyListeners();
  }

  int _selectedIndexCategory = 0;

  int get selectedIndexCategory => _selectedIndexCategory;

  void setSelectedIndexCategory(int value) {
    _selectedIndexCategory = value;
    notifyListeners();
  }

  TextEditingController _searchController = TextEditingController();

  TextEditingController get searchController => _searchController;

  void setTextController(String value) {
    _searchController.text = value;
    notifyListeners();
  }

  bool _isExpanded = false;
  bool get isExpanded => _isExpanded;

  void setExpanded(bool value) {
    _isExpanded = value;
    notifyListeners();
  }

  Future<ProductModel?> getProductById(int id) async {
    ProductModel? productModel;

    final result = await productGetProductByIdUseCase.call(id);

    await result.fold((l) async {
      print(l.errorMessage);
    }, (r) async {
      print(r.toJson());
      productModel = ProductModel.fromJson(r.toJson());
    });

    return productModel;
  }
}

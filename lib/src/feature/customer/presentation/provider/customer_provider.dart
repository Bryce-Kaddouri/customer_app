import 'package:flutter/material.dart';

import '../../business/usecase/customer_get_customer_by_id_usecase.dart';
import '../../data/model/customer_model.dart';

class CustomerProvider with ChangeNotifier {
  final CustomerGetCustomerByIdUseCase customerGetCustomerByIdUseCase;

  CustomerProvider({
    required this.customerGetCustomerByIdUseCase,
  });

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  int _nbItemPerPage = 10;

  int get nbItemPerPage => _nbItemPerPage;

  void setNbItemPerPage(int value) {
    _nbItemPerPage = value;
    notifyListeners();
  }

  String _searchText = '';

  String get searchText => _searchText;

  void setSearchText(String value) {
    _searchText = value;
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

  Future<CustomerModel?> getCustomerById(int id) async {
    CustomerModel? customerModel;
    final result = await customerGetCustomerByIdUseCase.call(id);

    await result.fold((l) async {
      print(l.errorMessage);
      print('error from getCustomerById');
      print(l);
    }, (r) async {
      print(r.toJson());
      customerModel = r;

      print('customerModel: $customerModel');
    });

    return customerModel;
  }
}

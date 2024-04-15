import 'package:customer_app/src/core/data/usecase/usecase.dart';
import 'package:customer_app/src/feature/notification/business/usecase/notification_get_notifications_usecase.dart';
import 'package:customer_app/src/feature/notification/data/model/notification_model.dart';
import 'package:flutter/material.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationGetNotificationsUseCase notificationGetNotificationsUseCase;

  NotificationProvider({
    required this.notificationGetNotificationsUseCase,
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

  Future<List<NotificationModel>?> getNotifications() async {
    List<NotificationModel>? notificationList;
    final result = await notificationGetNotificationsUseCase.call(NoParams());

    await result.fold((l) async {
      print(l.errorMessage);
      print('error from getCustomerById');
      print(l);
    }, (r) async {
      notificationList = r;

      print('notificationList: $notificationList');
    });

    return notificationList;
  }
}

import 'package:customer_app/src/feature/notification/data/model/notification_model.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/data/exception/failure.dart';
import '../../../../core/data/usecase/usecase.dart';

class NotificationDataSource {
  final _client = Supabase.instance.client;
  SupabaseClient _supaAdminClient = SupabaseClient('https://qlhzemdpzbonyqdecfxn.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFsaHplbWRwemJvbnlxZGVjZnhuIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcwNDg4NjgwNiwiZXhwIjoyMDIwNDYyODA2fQ.iGkTZL6qeM5f6kXobuo2b6CUdHigONycJuofyjWtEpU');

  Future<Either<DatabaseFailure, List<NotificationModel>>> getNotifications(NoParams params) async {
    print('getNotif');
    try {
      // where order_date >= current_date

      User? user = _client.auth.currentUser;
      if (user == null) {
        return Left(DatabaseFailure(errorMessage: 'User not logged in'));
      }
      String customerUid = user.id;
      List<NotificationModel> notificationList = [];

      List<Map<String, dynamic>> responseGeneral = await _client
          .from('all_notifications_view')
          .select()
          .isFilter('user_id', null) // or user_id is null or is equal to customerUid

          /* .eq('user_id', customerUid)*/

/*
          .isFilter('user_id', null)
*/
          .order('created_at', ascending: true);

      List<Map<String, dynamic>> responseCustomer = await _client
          .from('all_notifications_view')
          .select()
          .eq('user_id', customerUid) // or user_id is null or is equal to customerUid

          /* .eq('user_id', customerUid)*/

/*
          .isFilter('user_id', null)
*/
          .order('created_at', ascending: true);
      print('responseFuture');
      print(responseGeneral);

      if (responseGeneral.isNotEmpty) {
        notificationList.addAll(responseGeneral.map((e) => NotificationModel.fromJson(e)).toList());
      }

      if (responseCustomer.isNotEmpty) {
        notificationList.addAll(responseCustomer.map((e) => NotificationModel.fromJson(e)).toList());
      }

      notificationList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return Right(notificationList);
      /*.from('all_orders_view')
          .select();*/
/*
          .eq('supplier_id', supplierId)
*/
/*
          .order('order_time', ascending: true);
*/
    } on PostgrestException catch (error) {
      print('postgrest error');
      print(error);
      return Left(DatabaseFailure(errorMessage: error.message));
    } catch (e) {
      print(e);
      return Left(DatabaseFailure(errorMessage: 'Error getting orders'));
    }
  }
}

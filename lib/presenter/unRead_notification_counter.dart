import 'package:flutter/material.dart';
import '../repositories/notification_repository.dart';

class UnReadNotificationCounter extends ChangeNotifier {
  int unReadNotificationCounter = 0;

  getCount() async {
    var res = await NotificationRepository().getUnreadNotification();
    unReadNotificationCounter = res.count ?? 0;
    notifyListeners();
  }
}

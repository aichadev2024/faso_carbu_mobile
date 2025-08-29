import 'package:flutter/material.dart';
import 'package:faso_carbu_mobile/db/database_helper.dart';
import 'package:faso_carbu_mobile/models/notification_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> notifications = [];

  @override
  void initState() {
    super.initState();
    _chargerNotifications();
  }

  Future<void> _chargerNotifications() async {
    final data = await DatabaseHelper.instance.getAllNotifications();
    setState(() {
      notifications = data.reversed.toList();
    });
  }

  Future<void> _marquerCommeLu(int id) async {
    await DatabaseHelper.instance.marquerNotificationCommeLue(id);
    _chargerNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Mes Notifications 🔔',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.red.shade700,
        elevation: 2,
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                "Aucune notification pour l’instant 😊",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundColor: notif.lu == 1
                          ? Colors.grey.shade300
                          : Colors.red.shade700,
                      child: Icon(
                        notif.lu == 1
                            ? Icons.notifications_none
                            : Icons.notifications_active,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      notif.titre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          notif.message,
                          style: const TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '📅 ${notif.date}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            if (notif.lu == 0)
                              TextButton(
                                onPressed: () => _marquerCommeLu(notif.id!),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red.shade700,
                                ),
                                child: const Text("Marquer comme lu"),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

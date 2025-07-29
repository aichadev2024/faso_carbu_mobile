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
      appBar: AppBar(
        title: const Text('Mes notifications'),
        backgroundColor: const Color.fromARGB(255, 76, 168, 175),
      ),
      body: notifications.isEmpty
          ? const Center(child: Text("🔔 Aucune notification"))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Icon(
                      notif.lu == 1 ? Icons.notifications_none : Icons.notifications_active,
                      color: notif.lu == 1 ? Colors.grey : Colors.green,
                    ),
                    title: Text(
                      notif.titre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notif.message),
                        const SizedBox(height: 4),
                        Text(
                          '📅 ${notif.date}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        if (notif.lu == 0)
                          TextButton(
                            onPressed: () => _marquerCommeLu(notif.id!),
                            child: const Text('Marquer comme lu'),
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

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/pet.dart';
import '../models/vaccine.dart';
import 'database_service.dart';

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
  final DatabaseService _databaseService = DatabaseService();
  
  Future<void> initialize() async {
    // Initialize timezone data
    tz_data.initializeTimeZones();
    
    // Initialize notification settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
        
    const DarwinInitializationSettings initializationSettingsIOS = 
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) async {
        // Handle notification tap here
        print('Notification tapped: ${details.payload}');
      },
    );
    
    // Schedule check for upcoming vaccines
    await scheduleAllVaccineNotifications();
  }
  
  Future<void> scheduleAllVaccineNotifications() async {
    // Cancel all existing notifications first
    await notificationsPlugin.cancelAll();
    
    // Get all pets and their vaccines
    final List<Pet> pets = await _databaseService.getPets();
    
    for (final pet in pets) {
      if (pet.id == null) continue;
      
      final vaccines = await _databaseService.getVaccinesByPetId(pet.id!);
      
      for (final vaccine in vaccines) {
        if (vaccine.id == null) continue;
        
        final now = DateTime.now();
        final dueDate = vaccine.nextDueDate;
        final oneWeekBefore = dueDate.subtract(const Duration(days: 7));
        
        // If the due date is in the future, schedule notifications
        if (dueDate.isAfter(now)) {
          // Schedule notification for one week before
          if (oneWeekBefore.isAfter(now)) {
            await _scheduleNotification(
              id: int.parse(vaccine.id!.substring(0, 9)), // Use first 9 digits of ID as notification ID
              title: 'Lembrete de Vacina para ${pet.name}',
              body: 'A vacina ${vaccine.name} está programada para próxima semana (${_formatDate(dueDate)})',
              scheduledDate: oneWeekBefore,
              payload: 'vaccine_${vaccine.id}',
            );
          }
          
          // Schedule notification for the day of the vaccine
          await _scheduleNotification(
            id: int.parse(vaccine.id!.substring(0, 9)) + 1, // Increment ID for second notification
            title: 'Vacina para ${pet.name} Hoje!',
            body: 'Hoje é o dia da vacina ${vaccine.name} para ${pet.name}',
            scheduledDate: dueDate,
            payload: 'vaccine_${vaccine.id}',
          );
        }
      }
    }
  }
  
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload,
  }) async {
    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'vaccine_reminders',
          'Lembretes de Vacina',
            channelDescription: 'Notificações para vacinas agendadas',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // uiLocalNotificationDateInterpretation:
      //     UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: payload,
    );
  }
  
  // Schedule notification upon creating or updating a vaccine
  Future<void> scheduleVaccineNotification(Pet pet, Vaccine vaccine) async {
    if (vaccine.id == null) return;
    
    final now = DateTime.now();
    final dueDate = vaccine.nextDueDate;
    final oneWeekBefore = dueDate.subtract(const Duration(days: 7));
    
    // Cancel existing notifications for this vaccine
    final notificationId = int.parse(vaccine.id!.substring(0, 9));
    await notificationsPlugin.cancel(notificationId);
    await notificationsPlugin.cancel(notificationId + 1);
    
    // If the due date is in the future, schedule notifications
    if (dueDate.isAfter(now)) {
      // Schedule notification for one week before
      if (oneWeekBefore.isAfter(now)) {
        await _scheduleNotification(
          id: notificationId,
          title: 'Lembrete de Vacina para ${pet.name}',
          body: 'A vacina ${vaccine.name} está programada para próxima semana (${_formatDate(dueDate)})',
          scheduledDate: oneWeekBefore,
          payload: 'vaccine_${vaccine.id}',
        );
      }
      
      // Schedule notification for the day of the vaccine
      await _scheduleNotification(
        id: notificationId + 1,
        title: 'Vacina para ${pet.name} Hoje!',
        body: 'Hoje é o dia da vacina ${vaccine.name} para ${pet.name}',
        scheduledDate: dueDate,
        payload: 'vaccine_${vaccine.id}',
      );
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
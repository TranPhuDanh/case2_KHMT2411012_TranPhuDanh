import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/tasks/task_list_screen.dart';
import 'screens/tasks/task_detail_screen.dart';
import 'screens/tasks/task_create_screen.dart';
import 'screens/tasks/task_edit_screen.dart';
import 'screens/assignment/assign_task_screen.dart';
import 'screens/sharing/task_sharing_screen.dart';
import 'screens/notifications/notification_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  final bool loggedIn = await authService.isLoggedIn();

  runApp(TaskManagerApp(initialRoute: loggedIn ? '/tasks' : '/login'));
}

class TaskManagerApp extends StatelessWidget {
  final String initialRoute;

  const TaskManagerApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          primary: Colors.indigo,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.indigo, width: 2),
          ),
        ),
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/tasks': (context) => const TaskListScreen(),
        '/task-detail': (context) => const TaskDetailScreen(),
        '/task-create': (context) => const TaskCreateScreen(),
        '/task-edit': (context) => const TaskEditScreen(),
        '/assign-task': (context) => const AssignTaskScreen(),
        '/task-sharing': (context) => const TaskSharingScreen(),
        '/notifications': (context) => const NotificationScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

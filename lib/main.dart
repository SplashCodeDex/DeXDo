
import 'package:dexdo/repositories/todo_repository.dart';
import 'package:dexdo/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dexdo/screens/home_screen.dart';
import 'package:dexdo/widgets/error_boundary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the TodoRepository (in-memory for web compatibility)
final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepository();
});


void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: DeXDo()));
}

class DeXDo extends StatelessWidget {
  const DeXDo({super.key});

  @override
  Widget build(BuildContext context) {
    return AppErrorBoundary(
      child: MaterialApp(
        title: 'DeXDo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomePage(),
        builder: (context, child) {
          // Additional error boundary at the navigator level
          return ErrorBoundary(
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

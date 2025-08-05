
import 'package:dexdo/models/todo_model.dart';
import 'package:dexdo/repositories/todo_repository.dart';
import 'package:dexdo/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dexdo/screens/home_screen.dart';
import 'package:dexdo/widgets/error_boundary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

// Provider for the Isar instance
final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return await Isar.open(
    [TodoSchema],
    directory: dir.path,
  );
});

// Provider for the TodoRepository
final todoRepositoryProvider = FutureProvider<TodoRepository>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return TodoRepository(isar);
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

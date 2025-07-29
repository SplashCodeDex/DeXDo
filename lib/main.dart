
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dexdo/screens/home_screen.dart';
import 'package:dexdo/widgets/error_boundary.dart';

void main() {
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

  runApp(const DeXDo());
}

class DeXDo extends StatelessWidget {
  const DeXDo({super.key});

  @override
  Widget build(BuildContext context) {
    return AppErrorBoundary(
      child: MaterialApp(
        title: 'DeXDo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'System',
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purple.shade300,
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.purple.shade300,
            foregroundColor: Colors.white,
          ),
        ),
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

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loop_x/app_router.dart';
import 'package:loop_x/constants/theme.dart';
import 'core/supabase_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SupabaseClientManager.init();
  runApp(const ProviderScope(child: LoopXApp()));
}

class LoopXApp extends StatelessWidget {
  const LoopXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'loop_x',
      theme: appTheme,
      routerConfig: appRouter,
    );
  }
}

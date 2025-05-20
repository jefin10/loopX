import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'src/app.dart'; // your root widget

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Load env variables (await because it reads from disk).
  await dotenv.load(fileName: '.env');

  // 2) Initialize Supabase. This sets up the singleton client and
  //    attaches a secure storage provider (Keychain on iOS, Keystore on Android).
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,      // bang (!) means we KNOW it's not null
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authFlowType: AuthFlowType.pkce,       // modern OAuth flow, safer on mobile
  );

  // 3) Wrap the app in ProviderScope (Riverpod) so we can read providers anywhere.
  runApp(const ProviderScope(child: LoopXApp()));
}

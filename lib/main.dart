import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_bear_animation/screens/login_screen.dart';
import 'firebase_options.dart'; // Generado automáticamente por flutterfire configure

void main() async {
  // 1. Asegurar que los widgets estén listos antes de inicializar Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Inicializar Firebase usando las configuraciones de tu proyecto
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // 3. Enrutador: Escucha el estado de autenticación en tiempo real
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Si hay datos, la sesión está activa
          if (snapshot.hasData) {
            // Placeholder temporal para la Fase 4 (Pantalla principal)
            return Scaffold(
              appBar: AppBar(title: const Text('Home')),
              body: const Center(
                child: Text('¡Bienvenido! Sesión iniciada con éxito.'),
              ),
            );
          }
          // Si no hay sesión, mostramos tu pantalla de Login con Rive
          return const LoginScreen();
        },
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Importaciones de tus pantallas y configuración de Firebase
import 'package:login_bear_animation/screens/login_screen.dart';
import 'package:login_bear_animation/screens/home_screen.dart';
import 'firebase_options.dart';

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
          // Si el snapshot tiene datos, significa que hay un usuario logueado
          if (snapshot.hasData) {
            return const HomeScreen(); 
          }
          // Si no hay datos (snapshot vacío), mostramos la pantalla de Login con Rive
          return const LoginScreen();
        },
      ),
    );
  }
}

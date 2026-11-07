import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos el usuario actual para mostrar su correo
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          // Botón de Cierre de Sesión (Fase 4)
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Limpia el estado local y cierra sesión en Firebase
              await FirebaseAuth.instance.signOut();
              // NOTA: No necesitamos Navigator aquí porque el 
              // StreamBuilder en main.dart detectará el cambio automáticamente
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              '¡Sesión iniciada con éxito!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              user?.email ?? 'Usuario desconocido',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  
  bool _obscure = true;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _onSignUp() async {
    // Valida que el formulario cumpla con las reglas (email y password)
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Crear el usuario en Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      // 2. Opcional (Fase 3): Guardar datos básicos en Firestore
      if (userCredential.user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': _emailCtrl.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // 3. Regresar. El StreamBuilder de main.dart detectará la sesión 
      // y enviará al usuario a la pantalla principal automáticamente.
      if (mounted) Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? "An error occurred during sign up.";
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_errorMessage != null) ...[
                  Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 10),
                ],
                // Campo de Correo
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Email is required";
                    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                    if (!re.hasMatch(value)) return "Enter a valid email format";
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                // Campo de Contraseña
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Password is required";
                    if (value.length < 6) return "Password must be at least 6 characters";
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                // Botón de Registro
                MaterialButton(
                  minWidth: size.width,
                  height: 50,
                  color: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onPressed: _isLoading ? null : _onSignUp,
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Sign Up', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }
}
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart'; // Importación de Firebase
import 'package:login_bear_animation/screens/signup_screen.dart'; // Asegúrate de que esta ruta sea correcta

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscure = true;
  bool _isLoading = false; // Estado para bloquear el botón mientras carga

  // 1.1 Crear el cerebro de la animación del oso
  StateMachineController? _controller;
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;

  // 3.2 Variable del recorrido de la mirada
  SMINumber? _numLook;

  // 3.3 Timer para detener la mirada al dejar de escribir
  Timer? _typingDebounce;

  // Variables para el estado del "Remember Me" y el anti-spam
  bool _rememberMe = false;
  bool _isRememberToggling = false; // Bandera anti-spam solicitada en el reto

  // 2.1 Crear las variables para FocusNode
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  // 4.1 Controllers que manipulan lo que el usuario escribe
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  // Errores para mostrarlo en la UI
  String? emailError;
  String? passError;

  // 4.3 Validadores
  bool isValidEmail(String email) {
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }

  bool isValidPassword(String pass) { 
    final re = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$');
    return re.hasMatch(pass);
  }

  // =====================================================================
  // FASE 2: LÓGICA DE INICIO DE SESIÓN CON FIREBASE
  // =====================================================================
  Future<void> _onLogin() async {
    if (_isLoading) return;

    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    // Evaluar errores locales
    final eError = isValidEmail(email) ? null : "Invalid email format";
    final pError = isValidPassword(pass) ? null : "Invalid password format";

    setState(() {
      emailError = eError;
      passError = pError;
    });

    // Cerrar el teclado y bajar las manos
    FocusScope.of(context).unfocus();
    _typingDebounce?.cancel();
    _isChecking?.change(false);
    _isHandsUp?.change(false);
    _numLook?.value = 50.0;

    // Si hay error de validación, activar trigger de fallo y detener
    if (eError != null || pError != null) {
      _trigFail?.fire();
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Intentar iniciar sesión en Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
      
      // ÉXITO: El osito celebra
      _trigSuccess?.fire();
      
      // Esperamos un momento para que se vea la animación.
      // El StreamBuilder en main.dart hará el cambio de pantalla automáticamente.
      await Future.delayed(const Duration(seconds: 2));

    } on FirebaseAuthException catch (e) {
      // FALLO: El osito se entristece
      _trigFail?.fire();
      
      setState(() {
        if (e.code == 'user-not-found' || e.code == 'invalid-email') {
          emailError = 'No user found for that email.';
        } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
          passError = 'Wrong credentials provided.';
        } else {
          passError = 'Error: ${e.message}';
        }
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // =====================================================================
  // FASE 4: LÓGICA DE RECUPERACIÓN DE CONTRASEÑA
  // =====================================================================
  Future<void> _onForgotPassword() async {
    final email = _emailCtrl.text.trim();
    
    if (email.isEmpty || !isValidEmail(email)) {
      setState(() => emailError = "Enter a valid email first to reset password");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset link sent to $email')),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => emailError = e.message);
    }
  }

  // =====================================================================
  // MÉTODO ANTI-SPAM: Bloquea la UI durante la animación del "Remember Me"
  void _handleRememberMeChange(bool? value) async {
    if (_isRememberToggling) return; 

    setState(() {
      _isRememberToggling = true; 
    });

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    setState(() {
      _rememberMe = value ?? false;
      _isRememberToggling = false; 
    });
  }
  // =====================================================================

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() {
      if (_emailFocus.hasFocus) {
        if (_isHandsUp != null) {
          _isHandsUp?.change(false);
          _numLook?.value = 50.0;
        }
      }
    });
    _passwordFocus.addListener(() {
      _isHandsUp?.change(_passwordFocus.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Animación del Oso
                SizedBox(
                  width: size.width,
                  height: 200,
                  child: RiveAnimation.asset(
                    'assets/login-bear.riv',
                    stateMachines: const ['Login Machine'],
                    onInit: (artboard) {
                      _controller = StateMachineController.fromArtboard(
                        artboard,
                        'Login Machine',
                      );
                      if (_controller == null) return;
                      artboard.addController(_controller!);
                      _isChecking = _controller!.findSMI('isChecking');
                      _isHandsUp = _controller!.findSMI('isHandsUp');
                      _trigSuccess = _controller!.findSMI('trigSuccess');
                      _trigFail = _controller!.findSMI('trigFail');
                      _numLook = _controller!.findSMI('numLook');
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // Campo de Email
                TextField(
                  controller: _emailCtrl,
                  focusNode: _emailFocus,
                  onChanged: (value) {
                    if (_isChecking == null) return;
                    _isChecking!.change(true);
                    final look = (value.length / 80.0 * 100.0).clamp(0.0, 100.0);
                    _numLook?.value = look;

                    _typingDebounce?.cancel();
                    _typingDebounce = Timer(const Duration(seconds: 3), () {
                      if (!mounted) return;
                      _isChecking?.change(false);
                    });
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    errorText: emailError,
                    hintText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Campo de Password
                TextField(
                  controller: _passCtrl,
                  focusNode: _passwordFocus,
                  onChanged: (value) {
                    if (_isHandsUp == null) return;
                    _isHandsUp!.change(true);
                  },
                  obscureText: _obscure,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    errorText: passError,
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscure = !_obscure;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        AbsorbPointer(
                          absorbing: _isRememberToggling,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: _handleRememberMeChange,
                          ),
                        ),
                        const Text('Remember me'),
                      ],
                    ),
                    // BOTÓN DE RECUPERAR CONTRASEÑA (FASE 4)
                    GestureDetector(
                      onTap: _onForgotPassword,
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Botón de Login
                MaterialButton(
                  minWidth: size.width,
                  height: 50,
                  color: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onPressed: _isLoading ? null : _onLogin, // Bloqueo mientras carga
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Login', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 10),

                // Texto de Registro y Navegación (FASE 3)
                SizedBox(
                  width: size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Sign up',
                          style: TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
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
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _typingDebounce?.cancel();
    super.dispose();
  }
}
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async'; //3.1 Importar el timer

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscure = true;

  //1.1 crear el cerebro de la anmación
  StateMachineController? _controller;
  //SMI: State Machine Input / Entrada de máquina de estado
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;


  //3.2 variable del recorrido de la mirada
  SMINumber? _numLook;

  //3.3 Timer para detener la mirada al dejar de escribir
  Timer? _typingDebounce;


  //2.1 crear las variables para FocusNode
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  //4.1 controllers que manipulan lo que el usuario escribe
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  //Errores para mostrarlo en la UI
  String? emailError;
  String? passError;

  //4.3 Validadores
  bool isValidEmail(String email) {
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }

  bool isValidPassword(String pass) { 
  final re = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',);
  return re.hasMatch(pass);
  }

  //4.4 Dar acción al botón
  void _onLogin() {
    //4.5 De lo que escribio el usuario quitar espacios en blanco
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;


    //4.6 Evaluar los errores
    final eError = isValidEmail(email) ? null : "Invalid email";
    final pError = isValidPassword(pass) ? null : "Invalid password";

    //4.7 Avisar que hubo camios
    setState((){
    emailError = eError;
    passError = pError;
    });

    //4.8 Cerrar el teclado y bajar las manos
    FocusScope.of(context).unfocus(); //Quita el foco
    _typingDebounce?.cancel();
    _isChecking?.change(false);
    _isHandsUp?.change(false);
    _numLook?.value = 50.0;

    //4.9 Activar triggers
    if(eError == null && pError == null){
      _trigSuccess?.fire();
    } else {
     _trigFail?.fire();
    }
  }

  //2.2 Listeners (oyentes/chismosos)
  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() {
    if(_emailFocus.hasFocus) {
   //verificar que no sea nulo
   if(_isHandsUp !=null) {
    //manos abajo en el email
    _isHandsUp?.change(false);
    //3.4 Mirada neutra
    _numLook?.value = 50.0;
   }
   } 
    });
    _passwordFocus.addListener(() {
    //manos arriba en password
    _isHandsUp?.change(_passwordFocus.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    //Para obtener el tamaño de la pantalla
    final Size size =MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child:Column(
            children:[
            SizedBox(
              width: size.width,
              height:200,
              child: RiveAnimation.asset(
                'assets/login-bear.riv',
                stateMachines: ['Login Machine'],
                //1.2 vincular animación
                onInit: (artboard) {
                   _controller = StateMachineController.fromArtboard(
                    artboard,
                    'Login Machine',
                   );

                   //1.3 verificar que inicio bien
                   if(_controller == null) return;
                   //Agrega controlador al escenario
                   artboard.addController(_controller!);
                   //vinculamos variables
                   _isChecking = _controller!.findSMI('isChecking');
                   _isHandsUp = _controller!.findSMI('isHandsUp');
                   _trigSuccess = _controller!.findSMI('trigSuccess');
                   _trigFail = _controller!.findSMI('trigFail');
                   //3.5 vincular numLook
                   _numLook = _controller!.findSMI('numLook');
                },
              ),
            ),
             //para separar espacio
             SizedBox(height: 10),
             TextField(
              //4.10 Enlazar controller
              controller: _emailCtrl,
              //2.3 asignar foco al campo de texto
              focusNode: _emailFocus,
              onChanged: (value) {
                if(_isHandsUp != null) {
                  //no tapes los ojos al ver el email
                 //_isHandsUp!.change(false);
                }
                // si checking es nulo
                if(_isChecking == null) return;
                  //activa el modo chismoso
                  _isChecking!.change(true);
                //3.6 Implementar numLook
                //Ajustes de límites del 0 a 100
                //80 es la medida calibración
                 final look = (value.length / 80.0 *100.0).clamp ( 0.0, 100.0);
                //Clamp es el rango (abrazadera)
                _numLook?.value = look;

                //3.7 Debounce: si vuelve a teclear, reinicia el contador
                //Cancelar cualquier timer existente
                _typingDebounce?.cancel();
                //crear nuevo timer
                _typingDebounce = Timer(Duration(seconds: 3), (){
                  //si se cierra la pantalla, quita el contador
                  if (!mounted) return;
                  //Mirada neutra
                  _isChecking?.change(false);
                });
              },
              //para mostrar el tipo de teclado
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                //4.11 mostrar textfielderror
                errorText: emailError,
                hintText: 'Email',
                prefixIcon:const Icon(Icons.email),
                border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)
                )
              ),
             ),
             SizedBox(height: 10),
             //campo de texto para contraseña
             TextField(
              //4.10 Enlazar controller
              controller: _passCtrl,
              //2.3 asignar foco al campo de texto
              focusNode: _passwordFocus,
              onChanged: (value) {
                if(_isChecking != null) {
                  //no tapes los ojos al ver el email
                  //_isChecking!.change(false);
                }
                // si checking es nulo
                if(_isHandsUp == null) return;
                  //activa el modo chismoso
                  _isHandsUp!.change(true);
              },
              obscureText: _obscure,
              //Para mostrar el tipo de teclado
               keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                errorText: passError,
                hintText: 'Password',
                prefixIcon:const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: (){
                    //refrescar el icono
                    setState((){
                      _obscure = !_obscure;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  //para redondear bordes
                borderRadius: BorderRadius.circular(12),
                )
              ),
             ),
             SizedBox(height: 10),
             //4.12 Texto olvide mi contraseña
             SizedBox(
              width: size.width,
              child: const Text(
                'Forgot password?',
                //Alinear a la derecha
                textAlign: TextAlign.right,
                style: TextStyle(decoration: TextDecoration.underline)
                ),
             ),
             const SizedBox(height : 10),
             //4.13 boton del login
             MaterialButton(
              minWidth: size.width,
              height: 50,
              color: Colors.pinkAccent,
              shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(12),
              ),
              onPressed: _onLogin,
              child: Text('Login', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 10),
              //4.14 texto de registro
              SizedBox(
                width: size.width,
                child: Row (
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: (){},
                      child: Text('Sign up',
                      style: TextStyle(
                        color: Colors.black,
                        //Subrayado
                        decoration: TextDecoration.underline,
                        //negritas
                        fontWeight: FontWeight.bold,
                      ),
                      ),
                    ),
                  ]
                )
              )
            ],
          ),
          ),
      ),
    );
  }
  @override
  void dispose() {
    //4.15 Liberrar los controladores
    _emailCtrl.dispose();
    _passCtrl.dispose();
    // 2.4 Liberar espacio en memoria
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _typingDebounce?.cancel(); //3.9 Eliminar el timer
    super.dispose();
  }
}
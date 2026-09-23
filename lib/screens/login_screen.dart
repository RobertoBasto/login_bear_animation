import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

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


  //2.1 crear las variables para FocusNode
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

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
                },
              ),
            ),
             //para separar espacio
             SizedBox(height: 10),
             TextField(
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
              },
              //para mostrar el tipo de teclado
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
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
                hintText: 'Contraseña',
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
            ],
          ),
          ),
      ),
    );
  }
  @override
  void dispose() {
    // 2.4 Liberar espacio en memoria
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }
}
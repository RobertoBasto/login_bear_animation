import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscure = true;
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
              child: RiveAnimation.asset('login-bear.riv')
            ),
             //para separar espacio
             SizedBox(height: 10),
             TextField(
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
}
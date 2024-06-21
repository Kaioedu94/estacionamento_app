// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_constructors_in_immutables
// ignore_for_file: use_build_context_synchronously
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controller/login_controller.dart';
import '../components/my_text_field.dart';

class LoginView extends StatefulWidget {
    LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool signInRequired = false;
  IconData iconPassword = Icons.visibility;
  bool obscurePassword = true;
  String? _errorMsg;
  final TextEditingController _recoveryEmailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo estilizado
          Positioned(
            top: -MediaQuery.of(context).size.width * 0.3,
            right: -MediaQuery.of(context).size.width * 0.3,
            child: Container(
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ),
          Positioned(
            top: -MediaQuery.of(context).size.width * 0.3,
            right: -MediaQuery.of(context).size.width * 0.1,
            child: Container(
              height: MediaQuery.of(context).size.width / 1.3,
              width: MediaQuery.of(context).size.width / 1.3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
            child: Container(),
          ),
          // Conteúdo principal da tela de login
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding:   EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    Text(
                      'Login',
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                      SizedBox(height: 40),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: MyTextField(
                              controller: emailController,
                              hintText: 'Email',
                              obscureText: false,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon:   Icon(Icons.email),
                              errorMsg: _errorMsg,
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return 'Por favor, preencha o e-mail';
                                } else if (!RegExp(r'^[\w-\.]+@([\w-]+.)+[\w-]{2,4}$').hasMatch(val)) {
                                  return 'Por favor, digite um e-mail válido';
                                }
                                return null;
                              },
                            ),
                          ),
                            SizedBox(height: 10),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: MyTextField(
                              controller: passwordController,
                              hintText: 'Senha',
                              obscureText: obscurePassword,
                              keyboardType: TextInputType.visiblePassword,
                              prefixIcon:   Icon(Icons.lock),
                              errorMsg: _errorMsg,
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return 'Por favor, preencha a senha';
                                } else if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~`)\%\-(_+=;:,.<>/?"[{\]}\|^]).{8,}$').hasMatch(val)) {
                                  return 'Por favor, digite uma senha válida';
                                }
                                return null;
                              },
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                    iconPassword = obscurePassword ? Icons.visibility : Icons.visibility_off;
                                  });
                                },
                                icon: Icon(iconPassword),
                              ),
                            ),
                          ),
                            SizedBox(height: 20),
                          !signInRequired
                              ? SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.5,
                                  child: TextButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        setState(() {
                                          signInRequired = true;
                                        });
                                        LoginController()
                                            .login(context, emailController.text, passwordController.text)
                                            .then((value) {
                                          setState(() {
                                            signInRequired = false;
                                          });
                                        }).catchError((error) {
                                          setState(() {
                                            _errorMsg = 'Erro de login. Tente novamente.';
                                            signInRequired = false;
                                          });
                                        });
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      elevation: 3.0,
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(60),
                                      ),
                                    ),
                                    child:   Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                                      child: Text(
                                        'Entrar',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              :   CircularProgressIndicator(),
                            SizedBox(height: 10),
                          TextButton(
                            child:   Text(
                              'Esqueci a senha',
                              style: TextStyle(
                                color: Color.fromARGB(255, 23, 112, 185),
                              ),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title:   Text('Recuperação de Senha'),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: <Widget>[
                                            Text('Digite o e-mail para recuperar a senha.'),
                                          TextField(
                                            controller: _recoveryEmailController,
                                            decoration:   InputDecoration(
                                              labelText: 'E-mail',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child:   Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          try {
                                            await FirebaseAuth.instance.sendPasswordResetEmail(
                                              email: _recoveryEmailController.text,
                                            );
                                            Navigator.of(context).pop();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('E-mail de recuperação enviado'),
                                              ),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Erro ao enviar e-mail de recuperação'),
                                              ),
                                            );
                                          }
                                        },
                                        child:   Text('Enviar'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                            Text('Ainda não tem conta?'),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, 'cadastrar');
                                },
                                child: Text('Cadastre-se'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 200), // Espaçamento inferior 
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
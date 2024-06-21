// ignore_for_file: prefer_const_constructors

import 'dart:ui';
import 'package:flutter/material.dart';
import '../controller/login_controller.dart';
import '../components/my_text_field.dart';

class CadastrarView extends StatefulWidget {
  const CadastrarView({super.key});

  @override
  State<CadastrarView> createState() => _CadastrarViewState();
}

class _CadastrarViewState extends State<CadastrarView> {
  final txtNome = TextEditingController();
  final txtEmail = TextEditingController();
  final txtSenha = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  IconData iconPassword = Icons.visibility;
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    Text(
                      'Criar Conta',
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 40),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: MyTextField(
                              controller: txtNome,
                              hintText: 'Nome',
                              obscureText: false,
                              keyboardType: TextInputType.name,
                              prefixIcon: const Icon(Icons.person),
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return 'Por favor, preencha o nome';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: MyTextField(
                              controller: txtEmail,
                              hintText: 'Email',
                              obscureText: false,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: const Icon(Icons.email),
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
                          const SizedBox(height: 10),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: MyTextField(
                              controller: txtSenha,
                              hintText: 'Senha',
                              obscureText: obscurePassword,
                              keyboardType: TextInputType.visiblePassword,
                              prefixIcon: const Icon(Icons.lock),
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
                          const SizedBox(height: 40),
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(140, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(60),
                                ),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  LoginController().criarConta(
                                    context,
                                    txtNome.text,
                                    txtEmail.text,
                                    txtSenha.text,
                                  );
                                }
                              },
                              child: const Text('Cadastrar-se'),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Cancelar',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
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

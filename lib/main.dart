// ignore_for_file: prefer_const_constructors

import 'package:device_preview/device_preview.dart';
import 'package:estacionamento_app/view/entrada_saida_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'view/cadastrar_view.dart';
import 'view/login_view.dart';
import 'view/principal_view.dart';
import 'view/historico_view.dart';
import 'view/perfil_view.dart';

Future<void> main() async {
  // Inicialização do Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gerenciamento de Estacionamento',
      initialRoute: 'login',
      routes: {
        'login': (context) => LoginView(),
        'cadastrar': (context) => CadastrarView(),
        'principal': (context) => PrincipalView(),
        'historico': (context) => HistoricoView(),
        'perfil': (context) => PerfilView(),
        'entradaSaida': (context) => EntradaSaidaView(),
      },
      builder: DevicePreview.appBuilder, // Adiciona compatibilidade com DevicePreview
    );
  }
}

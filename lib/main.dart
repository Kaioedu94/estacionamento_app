// lib/main.dart

// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_preview/device_preview.dart';
import 'package:estacionamento_app/view/usuario/entrada_saida_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'view/admin/reservas_view.dart';
import 'view/admin/users_view.dart';
import 'view/cadastrar_view.dart';
import 'view/login_view.dart';
import 'view/usuario/principal_user_view.dart';
import 'view/usuario/historico_view.dart';
import 'view/usuario/perfil_view.dart';
import 'view/admin/principal_admin_view.dart';
import 'view/admin/monitoramento_view.dart';

Future<void> main() async {
  // Inicialização do Firebase
  WidgetsFlutterBinding.ensureInitialized();
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
        'principal': (context) => PrincipalUserView(),
        'historico': (context) => HistoricoView(),
        'perfil': (context) => PerfilView(),
        'principal_admin': (context) => PrincipalAdminView(),
        'entradaSaida': (context) => EntradaSaidaView(),
        'monitoramento': (context) => MonitoramentoView(),
        'usersView': (context) => UsersView(),
        'reservasView': (context) => ReservasView(),
      },
      builder: DevicePreview.appBuilder,
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return LoginView();
          } else {
            return FutureBuilder<bool>(
              future: checkIfAdmin(user),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData && snapshot.data == true) {
                  return PrincipalAdminView();
                } else {
                  return PrincipalUserView();
                }
              },
            );
          }
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<bool> checkIfAdmin(User user) async {
    final adminSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return adminSnapshot.data()?['isAdmin'] ?? false;
  }
}

// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoricoEntradasSaidasView extends StatefulWidget {
  const HistoricoEntradasSaidasView({super.key});

  @override
  State<HistoricoEntradasSaidasView> createState() => _HistoricoEntradasSaidasViewState();
}

class _HistoricoEntradasSaidasViewState extends State<HistoricoEntradasSaidasView> {
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de Entradas e Saídas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('entradas_saidas')
              .where('usuarioId', isEqualTo: _currentUser?.uid)
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro ao carregar dados: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Nenhum registro encontrado.'));
            } else {
              final eventos = snapshot.data!.docs;
              return ListView.builder(
                itemCount: eventos.length,
                itemBuilder: (context, index) {
                  final evento = eventos[index].data() as Map<String, dynamic>;
                  final statusColor = evento['tipo'] == 'entrada'
                      ? Colors.green[100]
                      : Colors.red[100];
                  return Card(
                    color: statusColor,
                    child: ListTile(
                      title: Text('Vaga: ${evento['numeroVaga']}'),
                      subtitle: Text('Data: ${evento['timestamp']?.toDate()}'),
                      trailing: Text('${evento['tipo']}'),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

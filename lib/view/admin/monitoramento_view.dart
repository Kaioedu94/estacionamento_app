// monitoramento_view.dart

// ignore_for_file: unused_field, prefer_const_constructors, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'dart:io';

class MonitoramentoView extends StatefulWidget {
  const MonitoramentoView({super.key});

  @override
  State<MonitoramentoView> createState() => _MonitoramentoViewState();
}

class _MonitoramentoViewState extends State<MonitoramentoView> {
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
        title: Text('Monitoramento de Entradas e Saídas'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _gerarRelatorio,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('entradas')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar dados.'));
          }

          final dados = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: dados.length,
            itemBuilder: (context, index) {
              final entradaSaida = dados[index].data() as Map<String, dynamic>;
              final operacao = entradaSaida['operacao'];
              final usuarioId = entradaSaida['usuarioId'];
              final numero = entradaSaida['numero'];
              final fileira = entradaSaida['fileira'];
              final timestamp = entradaSaida['timestamp'] as Timestamp;

              return ListTile(
                title: Text('Operação: $operacao'),
                subtitle: Text(
                    'Usuário: $usuarioId\nVaga: $numero\nFileira: $fileira\nData: ${timestamp.toDate()}'),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _gerarRelatorio() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('entradas')
          .orderBy('timestamp', descending: true)
          .get();
      final dados = snapshot.docs.map((doc) => doc.data()).toList();

      final rows = [
        ['Operação', 'Usuário', 'Número', 'Fileira', 'Data'],
      ];

      for (final dado in dados) {
        rows.add([
          dado['operacao'],
          dado['usuarioId'],
          dado['numero'],
          dado['fileira'],
          (dado['timestamp'] as Timestamp).toDate().toString(),
        ]);
      }

      final csv = const ListToCsvConverter().convert(rows);
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/relatorio_estacionamento.csv';
      final file = File(path);
      await file.writeAsString(csv);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Relatório gerado em $path')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro ao gerar relatório: $e')));
      if (kDebugMode) {
        print('Erro ao gerar relatório: $e');
      }
    }
  }
}

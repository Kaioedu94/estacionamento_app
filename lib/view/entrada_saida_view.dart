// lib/view/entrada_saida_view.dart

// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EntradaSaidaView extends StatefulWidget {
  const EntradaSaidaView({super.key});

  @override
  State<EntradaSaidaView> createState() => _EntradaSaidaViewState();
}

class _EntradaSaidaViewState extends State<EntradaSaidaView> {
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
        title: Text('Entrada e Saída'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reservas')
            .where('usuarioId', isEqualTo: _currentUser?.uid)
            .where('status', isEqualTo: true) // Considerando que 'status' seja booleano
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar reservas.'));
          }

          final reservas = snapshot.data?.docs ?? [];

          if (reservas.isEmpty) {
            return Center(child: Text('Nenhuma reserva encontrada.'));
          }

          return ListView.builder(
            itemCount: reservas.length,
            itemBuilder: (context, index) {
              final reserva = reservas[index];
              final reservaData = reserva.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text('Vaga ${reservaData['numero']} ${reservaData['fileira']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tipo: ${reservaData['tipo']}'),
                      Text('Data: ${reservaData['data']?.toDate()}'),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await _handleEntradaSaida(reserva.id, reservaData);
                    },
                    child: Text(
                      reservaData['entradaConfirmada'] == true ? 'Confirmar Saída' : 'Confirmar Entrada',
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleEntradaSaida(String reservaId, Map<String, dynamic> reservaData) async {
    if (_currentUser != null) {
      try {
        final entradaConfirmada = reservaData['entradaConfirmada'] == true;

        if (!entradaConfirmada) {
          // Confirmar Entrada
          await FirebaseFirestore.instance.collection('entradas').add({
            'usuarioId': _currentUser!.uid,
            'reservaId': reservaId,
            'numero': reservaData['numero'],
            'fileira': reservaData['fileira'],
            'tipo': reservaData['tipo'],
            'timestamp': FieldValue.serverTimestamp(),
            'operacao': 'entrada',
          });

          // Marcar a reserva como entrada confirmada
          await FirebaseFirestore.instance.collection('reservas').doc(reservaId).update({
            'entradaConfirmada': true,
          });

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Entrada confirmada.')));
        } else {
          // Confirmar Saída
          await FirebaseFirestore.instance.collection('entradas').add({
            'usuarioId': _currentUser!.uid,
            'reservaId': reservaId,
            'numero': reservaData['numero'],
            'fileira': reservaData['fileira'],
            'tipo': reservaData['tipo'],
            'timestamp': FieldValue.serverTimestamp(),
            'operacao': 'saida',
          });

          // Cancelar a reserva
          await FirebaseFirestore.instance.collection('reservas').doc(reservaId).update({
            'status': false, // Cancelada
            'entradaConfirmada': false,
          });

          // Atualizar a vaga como disponível
          final vagaQuery = await FirebaseFirestore.instance
              .collection('vagas')
              .where('numero', isEqualTo: reservaData['numero'])
              .where('fileira', isEqualTo: reservaData['fileira'])
              .get();

          if (vagaQuery.docs.isNotEmpty) {
            final vagaId = vagaQuery.docs.first.id;
            await FirebaseFirestore.instance.collection('vagas').doc(vagaId).update({
              'disponivel': true,
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saída confirmada e reserva cancelada.')));
        }
      } catch (e) {
        if (kDebugMode) {
          print('Erro ao confirmar entrada/saída: $e');
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao confirmar entrada/saída.')));
      }
    }
  }
}

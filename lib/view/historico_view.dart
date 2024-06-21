// ignore_for_file: prefer_const_constructors, sort_child_properties_last, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controller/reserva_controller.dart';

class HistoricoView extends StatefulWidget {
  const HistoricoView({super.key});

  @override
  State<HistoricoView> createState() => _HistoricoViewState();
}

class _HistoricoViewState extends State<HistoricoView> {
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
        title: Text('Histórico de Reservas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('reservas')
              .where('usuarioId', isEqualTo: _currentUser?.uid)
              .orderBy('data', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro ao carregar dados.'));
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Nenhuma reserva encontrada.'));
            } else {
              final reservas = snapshot.data!.docs;
              return ListView.builder(
                itemCount: reservas.length,
                itemBuilder: (context, index) {
                  final reserva = reservas[index].data() as Map<String, dynamic>;
                  final statusColor = _getStatusColor(reserva['status']);
                  final reservaId = reservas[index].id;

                  return Card(
                    color: statusColor,
                    child: ListTile(
                      title: Text('Vaga: ${reserva['numero']} ${reserva['fileira']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Data: ${reserva['data']?.toDate()}'),
                          Text('Tipo: ${reserva['tipo']}'),
                        ],
                      ),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Status: ${reserva['status']}'),
                          if (reserva['status'] == 'ativa')
                            ElevatedButton(
                              onPressed: () {
                                _confirmarCancelamento(context, reservaId, reserva['numero']);
                              },
                              child: Text('Cancelar'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white, backgroundColor: Colors.red,
                              ),
                            ),
                        ],
                      ),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ativa':
        return Colors.green[100]!;
      case 'concluída':
        return Colors.blue[100]!;
      case 'cancelada':
        return Colors.red[100]!;
      default:
        return Colors.grey[200]!;
    }
  }

  void _confirmarCancelamento(BuildContext context, String reservaId, String vagaNumero) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Cancelamento'),
          content: Text('Deseja realmente cancelar esta reserva?'),
          actions: <Widget>[
            TextButton(
              child: Text('Não'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Sim'),
              onPressed: () {
                Navigator.of(context).pop();
                _cancelarReserva(reservaId, vagaNumero);
              },
            ),
          ],
        );
      },
    );
  }

  void _cancelarReserva(String reservaId, String vagaNumero) async {
    try {
      await ReservaController().cancelarReserva(context, reservaId, vagaNumero);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reserva cancelada com sucesso.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao cancelar a reserva: $e')));
    }
  }
}

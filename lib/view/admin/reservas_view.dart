// reservas_view.dart

// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class ReservasView extends StatefulWidget {
  const ReservasView({super.key});

  @override
  State<ReservasView> createState() => _ReservasViewState();
}

class _ReservasViewState extends State<ReservasView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciamento de Reservas'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reservas')
            .where('status', isEqualTo: 'ativa')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar reservas.'));
          }

          final reservas = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: reservas.length,
            itemBuilder: (context, index) {
              final reserva = reservas[index];
              final reservaData = reserva.data() as Map<String, dynamic>;
              final statusColor = _getStatusColor(reservaData['status']);
              final reservaId = reservas[index].id;

              return Card(
                color: statusColor,
                child: ListTile(
                  title: Text('Vaga ${reservaData['numero']} ${reservaData['fileira']}'),
                  subtitle: Text('Usuário: ${reservaData['usuarioId']}'),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      _confirmarCancelamento(context, reservaId, reservaData['numero'], reservaData['fileira']);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, 
                      backgroundColor: Colors.red,
                    ),
                    child: Text('Cancelar'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmarCancelamento(BuildContext context, String reservaId, String numero, String fileira) {
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
                _cancelarReserva(reservaId, numero, fileira);
              },
            ),
          ],
        );
      },
    );
  }

  void _cancelarReserva(String reservaId, String numero, String fileira) async {
    try {
      // Atualizar o status da reserva para 'cancelada'
      await FirebaseFirestore.instance.collection('reservas').doc(reservaId).update({
        'status': 'cancelada',
      });

      // Buscar a vaga correspondente
      final vagaQuery = await FirebaseFirestore.instance
          .collection('vagas')
          .where('numero', isEqualTo: numero)
          .where('fileira', isEqualTo: fileira)
          .get();

      if (vagaQuery.docs.isNotEmpty) {
        final vagaId = vagaQuery.docs.first.id;

        // Atualizar o status da vaga para 'disponivel: true'
        await FirebaseFirestore.instance.collection('vagas').doc(vagaId).update({
          'disponivel': true,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reserva cancelada com sucesso.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao cancelar a reserva: $e')));
    }
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
}

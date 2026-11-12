import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/donation_provider.dart';
import '../widgets/impact_card.dart';

class ImpactPage extends StatelessWidget {
  const ImpactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DonationProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Impacto')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Resultados que buscamos',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text('Indicadores simples para acompanhar o reaproveitamento.'),
          const SizedBox(height: 20),
          ImpactCard(
            value: provider.donations.length.toString(),
            label: 'Doações publicadas',
            description: 'Total de excedentes cadastrados no aplicativo.',
          ),
          ImpactCard(
            value: provider.reservedCount.toString(),
            label: 'Reservadas',
            description: 'Doações aguardando retirada.',
          ),
          ImpactCard(
            value: '${provider.reusedKg.toStringAsFixed(1)} kg',
            label: 'Alimentos reaproveitados',
            description: 'Soma das doações com retirada confirmada.',
          ),
          const SizedBox(height: 12),
          const Card(
            color: Color(0xFFDDEBD8),
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'ODS 2 — Fome Zero e Agricultura Sustentável\nODS 12 — Consumo e Produção Responsáveis',
                style: TextStyle(fontWeight: FontWeight.bold, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

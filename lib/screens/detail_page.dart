import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/donation.dart';
import '../providers/auth_provider.dart';
import '../providers/donation_provider.dart';
import 'publish_page.dart';

class DetailPage extends StatelessWidget {
  final int donationId;

  const DetailPage({
    super.key,
    required this.donationId,
  });

  Future<void> edit(
    BuildContext context,
    Donation donation,
  ) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PublishPage(
          donationId: donation.id,
        ),
      ),
    );
  }

  Future<void> delete(
    BuildContext context,
    Donation donation,
  ) async {
    final provider = context.read<DonationProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir doação'),
        content: const Text(
          'Deseja realmente excluir esta doação?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await provider.delete(donation);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Doação excluída com sucesso.'),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  Color statusBackground(String status) {
    if (status == 'Reservado') return const Color(0xFFFFE9C6);
    if (status == 'Retirado') return const Color(0xFFDDEEE4);
    return const Color(0xFFE7F5EC);
  }

  Color statusForeground(String status) {
    if (status == 'Reservado') return const Color(0xFF996017);
    if (status == 'Retirado') return const Color(0xFF33644A);
    return const Color(0xFF1F7A4D);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DonationProvider>();
    final auth = context.watch<AuthProvider>();
    final donation = provider.findById(donationId);

    if (donation == null) {
      return const Scaffold(
        body: Center(
          child: Text('Doação não encontrada.'),
        ),
      );
    }

    final profile = auth.profile!;
    final isOwner = profile.isSupplier &&
        donation.ownerEmail.toLowerCase() == profile.email.toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalhes da doação',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          if (isOwner)
            IconButton(
              tooltip: 'Editar',
              onPressed: () => edit(context, donation),
              icon: const Icon(Icons.edit_outlined),
            ),
          if (isOwner)
            IconButton(
              tooltip: 'Excluir',
              onPressed: () => delete(context, donation),
              icon: const Icon(Icons.delete_outline),
            ),
          const SizedBox(width: 10),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth > 820
              ? 820.0
              : constraints.maxWidth;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            children: [
              Center(
                child: SizedBox(
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(26),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF123F2D),
                              Color(0xFF26734E),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.restaurant_outlined,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    donation.foodName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    donation.establishmentName,
                                    style: const TextStyle(
                                      color: Color(0xFFDCEAE1),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 11,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusBackground(donation.status),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      donation.status,
                                      style: TextStyle(
                                        color: statusForeground(donation.status),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.scale_outlined,
                              label: 'Quantidade',
                              value:
                                  '${donation.quantityKg.toStringAsFixed(1)} kg',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.event_outlined,
                              label: 'Validade',
                              value: donation.expiration,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.schedule_outlined,
                              label: 'Retirada',
                              value: donation.pickupTime,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF2DD),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.location_on_outlined,
                                  color: Color(0xFFC4771F),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Local de retirada',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF173126),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      donation.address,
                                      style: const TextStyle(
                                        color: Color(0xFF718078),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      if (!profile.isSupplier)
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: donation.status == 'Disponível'
                                ? () async {
                                    await provider.reserve(donation);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Doação reservada com sucesso.',
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                            icon: const Icon(Icons.bookmark_add_outlined),
                            label: Text(
                              donation.status == 'Disponível'
                                  ? 'Reservar doação'
                                  : donation.status,
                            ),
                          ),
                        )
                      else if (isOwner && donation.status == 'Reservado')
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () async {
                              await provider.confirmPickup(donation);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Retirada confirmada com sucesso.',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Confirmar retirada'),
                          ),
                        )
                      else if (profile.isSupplier)
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F4F1),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            isOwner
                                ? 'Use as ações do topo para editar ou excluir esta doação.'
                                : 'Esta doação pertence a outro fornecedor.',
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: const Color(0xFF1F7A4D),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF718078),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF173126),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

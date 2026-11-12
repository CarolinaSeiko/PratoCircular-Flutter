import 'package:flutter/material.dart';
import '../models/donation.dart';

class DonationCard extends StatelessWidget {
  final Donation donation;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;

  const DonationCard({
    super.key,
    required this.donation,
    required this.onTap,
    this.onFavorite,
  });

  Color _statusBackground() {
    if (donation.status == 'Reservado') {
      return const Color(0xFFFFE9C6);
    }
    if (donation.status == 'Retirado') {
      return const Color(0xFFDDEEE4);
    }
    return const Color(0xFFE7F5EC);
  }

  Color _statusForeground() {
    if (donation.status == 'Reservado') {
      return const Color(0xFF996017);
    }
    if (donation.status == 'Retirado') {
      return const Color(0xFF33644A);
    }
    return const Color(0xFF1F7A4D);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F4ED),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.restaurant_outlined,
                  color: Color(0xFF1F7A4D),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            donation.foodName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF173126),
                            ),
                          ),
                        ),
                        if (onFavorite != null)
                          IconButton(
                            onPressed: onFavorite,
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              donation.favorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: donation.favorite
                                  ? const Color(0xFFE05252)
                                  : const Color(0xFF6E7D74),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      donation.establishmentName,
                      style: const TextStyle(
                        color: Color(0xFF6E7D74),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          icon: Icons.scale_outlined,
                          label: '${donation.quantityKg.toStringAsFixed(1)} kg',
                        ),
                        _InfoChip(
                          icon: Icons.schedule_outlined,
                          label: donation.pickupTime,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: _statusBackground(),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            donation.status,
                            style: TextStyle(
                              color: _statusForeground(),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Icon(
                  Icons.chevron_right,
                  color: Color(0xFF9AA69F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7F4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: const Color(0xFF66776D),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF4D5F55),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

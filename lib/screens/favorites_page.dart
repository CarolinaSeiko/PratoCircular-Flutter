import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/donation_provider.dart';
import '../widgets/donation_card.dart';
import 'detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DonationProvider>();
    final favorites = provider.donations.where((item) => item.favorite).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: favorites.isEmpty
          ? const Center(child: Text('Nenhuma doação favoritada.'))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: favorites
                  .map(
                    (donation) => DonationCard(
                      donation: donation,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailPage(donationId: donation.id),
                        ),
                      ),
                      onFavorite: () => provider.toggleFavorite(donation),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

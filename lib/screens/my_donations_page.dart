import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/donation.dart';
import '../providers/auth_provider.dart';
import '../providers/donation_provider.dart';
import '../widgets/donation_card.dart';
import 'detail_page.dart';
import 'publish_page.dart';

class MyDonationsPage extends StatelessWidget {
  const MyDonationsPage({super.key});

  Future<void> openDetail(
    BuildContext context,
    Donation donation,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailPage(
          donationId: donation.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthProvider>().profile!;
    final provider = context.watch<DonationProvider>();
    final donations = provider.donations
        .where((item) => item.ownerEmail == profile.email)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas doações'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const PublishPage(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
      body: provider.loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : provider.error != null
              ? Center(
                  child: Text(provider.error!),
                )
              : donations.isEmpty
                  ? const Center(
                      child: Text('Nenhuma doação publicada.'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: donations.length,
                      itemBuilder: (context, index) {
                        final donation = donations[index];
                        return DonationCard(
                          donation: donation,
                          onTap: () => openDetail(
                            context,
                            donation,
                          ),
                        );
                      },
                    ),
    );
  }
}

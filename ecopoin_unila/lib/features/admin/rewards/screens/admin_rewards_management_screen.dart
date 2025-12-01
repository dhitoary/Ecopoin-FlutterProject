import 'package:flutter/material.dart';
import 'package:ecopoin_unila/services/rewards_service.dart';
import 'package:ecopoin_unila/features/admin/rewards/dialogs/add_reward_dialog.dart';
import 'package:ecopoin_unila/features/admin/rewards/dialogs/edit_reward_dialog.dart';
import 'package:ecopoin_unila/features/admin/rewards/widgets/reward_card_widget.dart';
import 'package:ecopoin_unila/app/config/app_colors.dart';

class AdminRewardsManagementScreen extends StatefulWidget {
  const AdminRewardsManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminRewardsManagementScreen> createState() =>
      _AdminRewardsManagementScreenState();
}

class _AdminRewardsManagementScreenState
    extends State<AdminRewardsManagementScreen> {
  final RewardsService _rewardsService = RewardsService();
  late TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  Future<void> _showAddRewardDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AddRewardDialog(),
    );
    if (result == true) setState(() {});
  }

  Future<void> _showEditRewardDialog(RewardModel reward) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditRewardDialog(reward: reward),
    );
    if (result == true) setState(() {});
  }

  Future<void> _deleteReward(String rewardId) async {
    try {
      await _rewardsService.deleteReward(rewardId);
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reward berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER (Tanpa Tombol Back Manual)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Manajemen Rewards',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 20, // Sedikit diperbesar
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFcfe7d9)),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari reward...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF4c9a6c),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: const Icon(
                              Icons.close,
                              color: Color(0xFF4c9a6c),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),

            // Rewards grid
            Expanded(
              child: StreamBuilder<List<RewardModel>>(
                stream: _searchQuery.isEmpty
                    ? _rewardsService.getRewardsStream()
                    : _rewardsService.searchRewardsStream(_searchQuery),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError)
                    return Center(child: Text('Error: ${snapshot.error}'));

                  final rewards = snapshot.data ?? [];

                  if (rewards.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.card_giftcard,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Belum ada reward'
                                : 'Reward tidak ditemukan',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.7,
                        ),
                    itemCount: rewards.length,
                    itemBuilder: (context, index) {
                      return RewardCardWidget(
                        reward: rewards[index],
                        onEdit: () => _showEditRewardDialog(rewards[index]),
                        onDelete: () => _deleteReward(rewards[index].id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRewardDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.textDark, size: 28),
      ),
    );
  }
}

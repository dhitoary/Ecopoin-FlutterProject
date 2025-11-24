import 'package:flutter/material.dart';
import 'package:ecopoin_unila/services/rewards_service.dart';

class EditRewardDialog extends StatefulWidget {
  final RewardModel reward;

  const EditRewardDialog({Key? key, required this.reward}) : super(key: key);

  @override
  State<EditRewardDialog> createState() => _EditRewardDialogState();
}

class _EditRewardDialogState extends State<EditRewardDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _categoryController;
  late TextEditingController _nameController;
  late TextEditingController _pointsController;
  late TextEditingController _quantityController;
  late TextEditingController _imageUrlController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController(text: widget.reward.category);
    _nameController = TextEditingController(text: widget.reward.name);
    _pointsController = TextEditingController(
      text: widget.reward.pointsRequired.toString(),
    );
    _quantityController = TextEditingController(
      text: widget.reward.quantity.toString(),
    );
    _imageUrlController = TextEditingController(
      text: widget.reward.imageUrl ?? '',
    );
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _nameController.dispose();
    _pointsController.dispose();
    _quantityController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final rewardsService = RewardsService();
      await rewardsService.updateReward(
        rewardId: widget.reward.id,
        category: _categoryController.text.trim(),
        name: _nameController.text.trim(),
        pointsRequired: int.parse(_pointsController.text),
        quantity: int.parse(_quantityController.text),
        imageUrl: _imageUrlController.text.trim().isNotEmpty
            ? _imageUrlController.text.trim()
            : null,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reward berhasil diperbarui'),
            backgroundColor: Color(0xFF13e76b),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit Reward',
                      style: TextStyle(
                        color: Color(0xFF0d1b13),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Category field
                Text(
                  'Kategori',
                  style: const TextStyle(
                    color: Color(0xFF0d1b13),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Voucher, Merchandise',
                    filled: true,
                    fillColor: const Color(0xFFe7f3ec),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFcfe7d9)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFcfe7d9)),
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Kategori tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Name field
                Text(
                  'Nama Reward',
                  style: const TextStyle(
                    color: Color(0xFF0d1b13),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Botol Minum Ramah Lingkungan',
                    filled: true,
                    fillColor: const Color(0xFFe7f3ec),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFcfe7d9)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFcfe7d9)),
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Nama reward tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Points field
                Text(
                  'Poin Minimal',
                  style: const TextStyle(
                    color: Color(0xFF0d1b13),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _pointsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Contoh: 150',
                    filled: true,
                    fillColor: const Color(0xFFe7f3ec),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFcfe7d9)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFcfe7d9)),
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Poin minimal tidak boleh kosong';
                    }
                    if (int.tryParse(value!) == null) {
                      return 'Harus berupa angka';
                    }
                    if (int.parse(value) <= 0) {
                      return 'Poin harus lebih dari 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Quantity field
                Text(
                  'Stok',
                  style: const TextStyle(
                    color: Color(0xFF0d1b13),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Contoh: 50',
                    filled: true,
                    fillColor: const Color(0xFFe7f3ec),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFcfe7d9)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFcfe7d9)),
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Stok tidak boleh kosong';
                    }
                    if (int.tryParse(value!) == null) {
                      return 'Harus berupa angka';
                    }
                    if (int.parse(value) < 0) {
                      return 'Stok tidak boleh negatif';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Image URL field
                Text(
                  'URL Gambar (Opsional)',
                  style: const TextStyle(
                    color: Color(0xFF0d1b13),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(
                    hintText: 'https://example.com/image.jpg',
                    filled: true,
                    fillColor: const Color(0xFFe7f3ec),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFcfe7d9)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFcfe7d9)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFcfe7d9)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              'Batal',
                              style: TextStyle(
                                color: Color(0xFF0d1b13),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _isLoading ? null : _submitForm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF13e76b),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF0d1b13),
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Simpan',
                                    style: TextStyle(
                                      color: Color(0xFF0d1b13),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

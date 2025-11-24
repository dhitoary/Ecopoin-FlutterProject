import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/config/app_colors.dart';
import '../../../../services/verification_service.dart';

class VerificationDetailScreen extends StatefulWidget {
  final String verificationId;
  final Map<String, dynamic> verificationData;

  const VerificationDetailScreen({
    Key? key,
    required this.verificationId,
    required this.verificationData,
  }) : super(key: key);

  @override
  State<VerificationDetailScreen> createState() =>
      _VerificationDetailScreenState();
}

class _VerificationDetailScreenState extends State<VerificationDetailScreen> {
  final VerificationService _verificationService = VerificationService();
  bool _isLoading = false;
  final TextEditingController _rejectionReasonController =
      TextEditingController();

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.verificationData;
    final status = data['status'] as String;
    final depositAmount = (data['depositAmount'] ?? 0) as num;
    final userId = data['userId'] as String;
    final photoUrl = data['photoUrl'] as String?;
    final type = data['type'] as String?;
    final note = data['note'] as String?;
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Detail Verifikasi",
          style: TextStyle(color: AppColors.textDark),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Photo Preview
            if (photoUrl != null && photoUrl.isNotEmpty)
              Container(
                height: 300,
                color: Colors.grey[200],
                child: Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gagal memuat foto',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusLabel(status),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(status),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Detail Information
                  _buildDetailRow("Deposit Amount", "${depositAmount}kg"),
                  _buildDetailRow(
                    "Tanggal",
                    createdAt != null
                        ? DateFormat('dd MMM yyyy HH:mm').format(createdAt)
                        : 'N/A',
                  ),
                  if (type != null) _buildDetailRow("Tipe", type),
                  if (note != null) _buildDetailRow("Catatan", note),
                  _buildDetailRow("User ID", userId),

                  // Calculate points
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Informasi Poin",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Jika disetujui, user akan mendapat:",
                          style: TextStyle(
                            color: AppColors.textDark.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${(depositAmount * 10).toInt()} poin",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Perhitungan: ${depositAmount}kg × 10 poin/kg",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textDark.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action Buttons
                  if (status == 'pending') ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _handleReject,
                            icon: const Icon(Icons.close),
                            label: const Text("Tolak"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              disabledBackgroundColor: Colors.grey[300],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _handleApprove,
                            icon: const Icon(Icons.check),
                            label: const Text("Setujui"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              disabledBackgroundColor: Colors.grey[300],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textDark.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  Future<void> _handleApprove() async {
    setState(() => _isLoading = true);

    try {
      await _verificationService.approveVerification(
        verificationId: widget.verificationId,
        userId: widget.verificationData['userId'],
        depositAmount: ((widget.verificationData['depositAmount'] ?? 0) as num)
            .toDouble(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Setoran berhasil disetujui!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleReject() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Setoran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Masukkan alasan penolakan:'),
            const SizedBox(height: 12),
            TextField(
              controller: _rejectionReasonController,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Contoh: Foto tidak jelas, jenis sampah tidak sesuai',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _submitRejection();
            },
            child: const Text('Tolak', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRejection() async {
    if (_rejectionReasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alasan penolakan harus diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _verificationService.rejectVerification(
        verificationId: widget.verificationId,
        userId: widget.verificationData['userId'],
        rejectionReason: _rejectionReasonController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Setoran berhasil ditolak'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

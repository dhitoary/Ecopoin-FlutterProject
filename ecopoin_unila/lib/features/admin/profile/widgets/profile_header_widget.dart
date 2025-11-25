import 'package:flutter/material.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final String name;
  final String role;
  final String photoUrl;

  const ProfileHeaderWidget({
    Key? key,
    required this.name,
    required this.role,
    required this.photoUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        children: [
          // Profile Photo
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: photoUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(photoUrl),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {},
                    )
                  : null,
              color: photoUrl.isEmpty ? Colors.grey[300] : null,
            ),
            child: photoUrl.isEmpty
                ? const Icon(Icons.person, size: 56, color: Colors.grey)
                : null,
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Role
          Text(
            role,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF00A551),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

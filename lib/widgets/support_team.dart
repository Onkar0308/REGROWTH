import 'package:flutter/material.dart';
import '../../utils/contants.dart';

class SupportTeamScreen extends StatelessWidget {
  SupportTeamScreen({super.key});

  final List<TeamMember> teamMembers = [
    TeamMember(
        name: 'Mr. Neeraj Kulkarni',
        role: 'Project Director',
        phone: '+91 88305 59068',
        imagePath: 'assets/images/neeraj_profile.png'),
    TeamMember(
        name: 'Mr. Ajit Lohokare',
        role: 'Project Director',
        phone: '+91 90110 24422',
        imagePath: 'assets/images/ajit_profile.png'),
    TeamMember(
        name: 'Omkar Joshi',
        role: 'Techical Lead',
        phone: '+91 80878 03157',
        imagePath: 'assets/images/omkar_profile.png'),
    TeamMember(
        name: 'Rohan Kudale',
        role: 'Backend Developer',
        phone: '+91 83799 02131',
        imagePath: 'assets/images/rohan_profile.png'),
    TeamMember(
        name: 'Harshal Korade',
        role: 'App Developer',
        phone: '+91 86698 28982',
        imagePath: 'assets/images/harshal_profile.jpg'),
    TeamMember(
        name: 'Aniket Lokare',
        role: 'Web Developer',
        phone: '+91 96655 22654',
        imagePath: 'assets/images/aniket_profile.png'),
    // Add more team members as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Our Team',
          style: TextStyle(fontFamily: 'Lexend'),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: teamMembers.length,
        itemBuilder: (context, index) {
          final member = teamMembers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(member.imagePath),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.name,
                          style: const TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textblue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            member.role,
                            style: const TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 12,
                                color: AppColors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 16,
                              color: Colors.black.withOpacity(0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              member.phone,
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 14,
                                color: Colors.black.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TeamMember {
  final String name;
  final String role;
  final String phone;

  final String imagePath;

  TeamMember({
    required this.name,
    required this.role,
    required this.phone,
    required this.imagePath,
  });
}

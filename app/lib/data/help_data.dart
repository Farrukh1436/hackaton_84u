
import 'package:flutter/material.dart';

class HelpTopic {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String headline;
  final String content;

  HelpTopic({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.headline,
    required this.content,
  });
}

class HelpData {
  static List<HelpTopic> topics = [
    HelpTopic(
      title: 'CPR (Cardiopulmonary Resuscitation)',
      subtitle: 'Learn basic life-saving CPR techniques',
      icon: Icons.favorite,
      color: Colors.red,
      headline: 'How to Perform CPR',
      content: 'Placeholder content for CPR instructions. This will be filled with actual medical guidance.',
    ),
    HelpTopic(
      title: 'Allergy Response',
      subtitle: 'How to handle allergic reactions',
      icon: Icons.warning,
      color: Colors.orange,
      headline: 'Responding to Allergic Reactions',
      content: 'Placeholder content for allergy response. This will be filled with actual medical guidance.',
    ),
    HelpTopic(
      title: 'Heart Attack',
      subtitle: 'Recognizing and responding to heart attacks',
      icon: Icons.monitor_heart,
      color: Colors.red[700]!,
      headline: 'Heart Attack Emergency Response',
      content: 'Placeholder content for heart attack response. This will be filled with actual medical guidance.',
    ),
    HelpTopic(
      title: 'Choking',
      subtitle: 'First aid for choking emergencies',
      icon: Icons.air,
      color: Colors.blue,
      headline: 'Heimlich Maneuver and Choking Response',
      content: 'Placeholder content for choking response. This will be filled with actual medical guidance.',
    ),
    HelpTopic(
      title: 'Burns',
      subtitle: 'Treating different types of burns',
      icon: Icons.local_fire_department,
      color: Colors.deepOrange,
      headline: 'Burn Treatment and Care',
      content: 'Placeholder content for burn treatment. This will be filled with actual medical guidance.',
    ),
  ];
}
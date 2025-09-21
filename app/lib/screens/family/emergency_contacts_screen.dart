// screens/emergency_contacts_screen.dart
import 'package:flutter/material.dart';
import '../../services/api/family_api_service.dart';

import '../../services/family_storage_service.dart';
import '../../models/family_models.dart';
import '../../language/language_controller.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  List<FamilyMember> allMembers = [];
  List<FamilyMember> emergencyContacts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      // Load all family members
      allMembers = await FamilyStorageService.getFamilyMembers();

      // If no data in storage, fetch from API
      if (allMembers.isEmpty) {
        final response = await FamilyApiService.getSelectableMembers();
        if (response['success'] && response['data'] != null) {
          final List<dynamic> membersData = response['data'];
          allMembers = membersData.map((m) => FamilyMember.fromJson(m)).toList();
        }
      }

      // Filter emergency contacts (assuming members with certain relations)
      emergencyContacts = allMembers.where((member) =>
      member.relation == 'emergency' ||
          member.relation == 'family' ||
          member.isEmergencyContact == true
      ).toList();

    } catch (e) {
      print('Error loading emergency contacts: $e');
    }

    setState(() => isLoading = false);
  }

  Future<void> _toggleEmergencyContact(FamilyMember member) async {
    try {
      final newEmergencyStatus = !member.isEmergencyContact;

      final updateRequest = UpdateMemberRequest(
        name: member.name,
        phone: member.phone,
        isEmergencyContact: newEmergencyStatus,
        relation: member.relation,
      );

      final response = await FamilyApiService.updateMember(member.memberId, updateRequest);

      if (response['success']) {
        // Update the member in the allMembers list
        final memberIndex = allMembers.indexWhere((m) => m.memberId == member.memberId);
        if (memberIndex != -1) {
          allMembers[memberIndex] = member.copyWith(isEmergencyContact: newEmergencyStatus);
        }

        // Save to storage
        await FamilyStorageService.updateMemberInStorage(allMembers[memberIndex]);

        // Reload data to refresh the UI
        _loadData();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newEmergencyStatus
                ? '${member.name} added to emergency contacts'
                : '${member.name} removed from emergency contacts'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to update contact')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating contact: $e')),
      );
    }
  }  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Contacts'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Emergency Contacts Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: Colors.red[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.emergency, color: Colors.red[700]),
                    SizedBox(width: 8),
                    Text(
                      'Emergency Contacts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text('${emergencyContacts.length} contacts selected'),
              ],
            ),
          ),

          // Emergency Contacts List
          if (emergencyContacts.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Current Emergency Contacts',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ...emergencyContacts.map((contact) => Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red[100],
                  child: Icon(Icons.emergency, color: Colors.red[700]),
                ),
                title: Text(contact.name),
                subtitle: Text(contact.phone ?? "No phone"),
                trailing: Icon(Icons.priority_high, color: Colors.red),
              ),
            )).toList(),
          ],

          // All Members Section
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'All Family Members',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  'Tap to toggle emergency contact',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          Expanded(
            child: allMembers.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.contacts, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No family members found'),
                  SizedBox(height: 8),
                  Text('Add family members first in Family Circle'),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: allMembers.length,
              itemBuilder: (context, index) {
                final member = allMembers[index];
                final isEmergency = member.isEmergencyContact == true ||
                    emergencyContacts.any((ec) => ec.memberId == member.memberId);

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isEmergency
                          ? Colors.red[100]
                          : Colors.grey[200],
                      child: Icon(
                        isEmergency ? Icons.emergency : Icons.person,
                        color: isEmergency ? Colors.red[700] : Colors.grey,
                      ),
                    ),
                    title: Text(member.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member.phone ?? 'No phone'),
                        Text(
                          member.relation,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: Switch(
                      value: isEmergency,
                      onChanged: (value) => _toggleEmergencyContact(member),
                      activeColor: Colors.red[700],
                    ),
                    onTap: () => _toggleEmergencyContact(member),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
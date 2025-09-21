// screens/family_circle_screen.dart
import 'package:flutter/material.dart';
import '../../services/api/family_api_service.dart';
import '../../services/family_storage_service.dart';
import '../../models/family_models.dart';
import '../../language/language_controller.dart';

class FamilyCircleScreen extends StatefulWidget {
  const FamilyCircleScreen({super.key});

  @override
  State<FamilyCircleScreen> createState() => _FamilyCircleScreenState();
}

class _FamilyCircleScreenState extends State<FamilyCircleScreen> {
  List<FamilyMember> members = [];
  FamilyGroup? familyGroup;
  bool isLoading = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _selectedRelation = 'family';

  @override
  void initState() {
    super.initState();
    _loadFamilyData();
  }

  Future<void> _loadFamilyData() async {
    setState(() => isLoading = true);

    try {
      // Try to load from storage first
      familyGroup = await FamilyStorageService.getFamilyGroup();
      members = await FamilyStorageService.getFamilyMembers();

      // If no data in storage, fetch from API
      if (familyGroup == null) {
        final response = await FamilyApiService.getMyGroup();
        if (response['success'] && response['data'] != null) {
          familyGroup = FamilyGroup.fromJson(response['data']);
          members = familyGroup?.members ?? [];
          await FamilyStorageService.saveFamilyGroup(familyGroup!);
          await FamilyStorageService.saveFamilyMembers(members);
        }
      }
    } catch (e) {
      print('Error loading family data: $e');
    }

    setState(() => isLoading = false);
  }

  Future<void> _addMember() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Name and phone are required')),
      );
      return;
    }

    final request = AddMemberRequest(
      name: _nameController.text,
      phone: _phoneController.text,
        relation: _selectedRelation,
    );

    try {
      final response = await FamilyApiService.addMember(request);
      if (response['success']) {
        _nameController.clear();
        _phoneController.clear();
        _emailController.clear();
        Navigator.pop(context);
        _loadFamilyData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Member added successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to add member')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding member: $e')),
      );
    }
  }

  Future<void> _removeMember(String memberId) async {
    try {
      final response = await FamilyApiService.removeMember(memberId);
      if (response['success']) {
        await FamilyStorageService.removeMemberFromStorage(memberId);
        _loadFamilyData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Member removed successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to remove member')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing member: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Family Circle'),
        backgroundColor: Colors.teal[700],
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          if (familyGroup != null) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              color: Colors.teal[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    familyGroup!.groupName,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text('${members.length} members'),
                ],
              ),
            ),
          ],
          Expanded(
            child: members.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_add, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No family members yet'),
                  SizedBox(height: 8),
                  Text('Add your first family member'),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal[100],
                      child: Icon(Icons.person, color: Colors.teal[700]),
                    ),
                    title: Text(member.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member.phone ?? 'No phone'),
                        Text(member.relation, style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteConfirmation(member),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMemberDialog,
        backgroundColor: Colors.teal[700],
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Family Member'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name *'),
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number *'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email (optional)'),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRelation,
                decoration: InputDecoration(labelText: 'Relation'),
                items: ['family', 'friend', 'colleague', 'other']
                    .map((relation) => DropdownMenuItem(
                  value: relation,
                  child: Text(relation),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedRelation = value!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addMember,
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(FamilyMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Member'),
        content: Text('Are you sure you want to remove ${member.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _removeMember(member.memberId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
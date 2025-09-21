import 'package:flutter/material.dart';
import 'package:talaba_plus/language/language_controller.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../../models/emergency_request.dart';
import '../../models/family_models.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/api/api_service.dart';
import '../../services/api/family_api_service.dart';
import '../../services/api/url.dart';
import '../../services/storage_service.dart';
import '../../services/family_storage_service.dart';
import 'home_screen.dart';
import 'package:http/http.dart' as http;



enum HelpRequestType { me, other, familyMember }

class RequestHelpScreen extends StatefulWidget {
  final EmergencyType type;
  final bool isOnline;

  const RequestHelpScreen({super.key, required this.type, required this.isOnline});

  @override
  _RequestHelpScreenState createState() => _RequestHelpScreenState();
}

class _RequestHelpScreenState extends State<RequestHelpScreen> {
  static const String YANDEX_API_KEY = Urls.yandexMapDecoderApiKey;


  HelpRequestType _requestType = HelpRequestType.me;
  final _detailsController = TextEditingController();
  final _locationController = TextEditingController();
  String? _imagePath;
  bool _isLoading = false;
  double? _latitude;
  double? _longitude;
  String? _locationError;
  bool _isGettingLocation = false;
  String? _decodedAddress;
  // Family members data
  List<FamilyMember> _familyMembers = [];
  FamilyMember? _selectedFamilyMember;
  bool _loadingFamilyMembers = false;

  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
    _getCurrentLocation(); // Add this line
  }

  Future<void> _loadFamilyMembers() async {
    setState(() => _loadingFamilyMembers = true);

    try {
      // Try to get family members from local storage first
      final localMembers = await FamilyStorageService.getFamilyMembers();

      if (localMembers.isNotEmpty) {
        setState(() {
          _familyMembers = localMembers;
          _loadingFamilyMembers = false;
        });
      } else if (widget.isOnline) {
        // If no local data and online, try to fetch from API
        final response = await FamilyApiService.getSelectableMembers();

        if (response['success'] == true && response['data'] != null) {
          final List<dynamic> membersData = response['data']['members'] ?? [];
          final members = membersData.map((data) => FamilyMember.fromJson(data)).toList();

          setState(() {
            _familyMembers = members;
            _loadingFamilyMembers = false;
          });
        } else {
          setState(() => _loadingFamilyMembers = false);
        }
      } else {
        setState(() => _loadingFamilyMembers = false);
      }
    } catch (e) {
      print('Error loading family members: $e');
      setState(() => _loadingFamilyMembers = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {

      _isGettingLocation = false;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          _locationError = 'Location services are disabled';
          _isGettingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = 'Location permissions are denied';
            _isGettingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'Location permissions are permanently denied';
          _isGettingLocation = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationError = null;
        _isGettingLocation = false;
      });

      if (widget.isOnline) {
        _reverseGeocodeLocation(position.latitude, position.longitude);
      }
    } catch (e) {
      setState(() {
        _locationError = 'Failed to get location: $e';
        _isGettingLocation = false;
      });
    }
  }

  Future<void> _reverseGeocodeLocation(double latitude, double longitude) async {
    try {
      final url = 'https://geocode-maps.yandex.ru/v1/?apikey=$YANDEX_API_KEY&geocode=$longitude,$latitude&lang=en_US&format=json&results=1';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final geoObjects = data['response']['GeoObjectCollection']['featureMember'];

        if (geoObjects.isNotEmpty) {
          final geoObject = geoObjects[0]['GeoObject'];
          final address = geoObject['metaDataProperty']['GeocoderMetaData']['text'];

          setState(() {
            _decodedAddress = address;
          });
        }
      }
    } catch (e) {
      print('Error reverse geocoding: $e');
      setState(() {
        _decodedAddress = 'Unable to get address';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header Section with Gradient
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red[700]!, Colors.red[300]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(8, 0, 24, 10),
                child: Column(
                  children: [
                    // App Bar Content
                    Row(
                      children: [
                       IconButton(
                         padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),

                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _getServiceName(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.isOnline ? Icons.wifi : Icons.wifi_off,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                widget.isOnline ? 'Online' : 'Offline',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    // Hero Section
                    Row(
                      children: [
                        SizedBox(width: 16),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(
                            _getServiceIcon(),
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                LanguageController.get('emergency_request') ?? 'Emergency Request',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                LanguageController.get('provide_details') ?? 'Please provide details about the emergency',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Offline Warning Banner
          if (!widget.isOnline)
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[300]!),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.sms,
                      color: Colors.orange[700],
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LanguageController.get('offline_mode') ?? 'Offline Mode',
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          LanguageController.get('sms_only') ?? 'Emergency request will be sent via SMS',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Who needs help section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.help_outline,
                                  color: Colors.blue[600],
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                LanguageController.get('who_needs_help') ?? 'Who needs help?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),

                          // Request type selection
                          _buildRequestTypeCard(
                            HelpRequestType.me,
                            Icons.person,
                            LanguageController.get('me') ?? 'Me',
                            LanguageController.get('i_need_help') ?? 'I need help',
                          ),
                          SizedBox(height: 12),
                          _buildRequestTypeCard(
                            HelpRequestType.other,
                            Icons.person_outline,
                            LanguageController.get('other_person') ?? 'Other Person',
                            LanguageController.get('someone_else_needs_help') ?? 'Someone else needs help',
                          ),
                          SizedBox(height: 12),
                          _buildRequestTypeCard(
                            HelpRequestType.familyMember,
                            Icons.family_restroom,
                            LanguageController.get('family_member') ?? 'Family Member',
                            LanguageController.get('family_member_needs_help') ?? 'My family member needs help',
                            enabled: _familyMembers.isNotEmpty,
                            trailing: _loadingFamilyMembers
                                ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                                : null,
                          ),
                        ],
                      ),
                    ),

                    // Family member selection
                    if (_requestType == HelpRequestType.familyMember) ...[
                      SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.purple[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.family_restroom,
                                    color: Colors.purple[600],
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  LanguageController.get('select_family_member') ?? 'Select Family Member',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            if (_familyMembers.isEmpty)
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.orange.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline, color: Colors.orange),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        LanguageController.get('no_family_members_found') ?? 'No family members found.',
                                        style: TextStyle(color: Colors.orange.shade800),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              DropdownButtonFormField<FamilyMember>(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                value: _selectedFamilyMember,
                                hint: Text(LanguageController.get('choose_family_member') ?? 'Choose family member'),
                                items: _familyMembers.map((member) {
                                  return DropdownMenuItem<FamilyMember>(
                                    value: member,
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: Colors.blue[100],
                                          child: Text(
                                            member.name[0].toUpperCase(),
                                            style: TextStyle(
                                              color: Colors.blue[700],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              member.name,
                                              style: TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              member.relation,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (FamilyMember? newValue) {
                                  setState(() => _selectedFamilyMember = newValue);
                                },
                              ),
                          ],
                        ),
                      ),
                    ],

                    // Additional details section
                    if (_requestType != HelpRequestType.me) ...[
                      SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.description,
                                    color: Colors.green[600],
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  LanguageController.get('additional_details') ?? 'Additional Details',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _detailsController,
                              decoration: InputDecoration(
                                hintText: _requestType == HelpRequestType.familyMember
                                    ? LanguageController.get('describe_family_member') ?? 'Describe what happened to your family member...'
                                    : LanguageController.get('describe_situation') ?? 'Describe the situation...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              maxLines: 4,
                            ),
                            if (widget.isOnline) ...[
                              SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _takePicture,
                                  icon: Icon(_imagePath == null ? Icons.camera_alt : Icons.check_circle),
                                  label: Text(
                                    _imagePath == null
                                        ? LanguageController.get('take_photo') ?? 'Take Photo'
                                        : LanguageController.get('photo_taken') ?? 'Photo Taken',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _imagePath == null ? Colors.grey[600] : Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    // Location section
                    SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.red[600],
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                LanguageController.get('location') ?? 'Location',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Spacer(),
                              if (_isGettingLocation)
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              else
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.refresh, color: Colors.blue[600], size: 18),
                                    onPressed: _getCurrentLocation,
                                    tooltip: 'Refresh location',
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 16),

                          // Location status
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _locationError != null ? Colors.red[50] : Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _locationError != null ? Colors.red[200]! : Colors.green[200]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _locationError != null ? Icons.error_outline : Icons.check_circle_outline,
                                  color: _locationError != null ? Colors.red[600] : Colors.green[600],
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (_locationError != null)
                                        Text(
                                          _locationError!,
                                          style: TextStyle(color: Colors.red[700], fontSize: 12),
                                        )
                                      else if (_latitude != null && _longitude != null) ...[
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Location acquired:',
                                              style: TextStyle(
                                                color: Colors.green[700],
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(width: 2), // spacing
                                            Text(
                                              'Lat: ${_latitude!.toStringAsFixed(4)}, Lng: ${_longitude!.toStringAsFixed(4)}',
                                              style: TextStyle(color: Colors.green[600], fontSize: 12),
                                            ),
                                          ],
                                        ),


                                        if (_decodedAddress != null) ...[
                                          SizedBox(height: 4),
                                          Text(
                                            _decodedAddress!,
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ] else
                                        Text(
                                          'Getting current location...',
                                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 16),
                          TextFormField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              hintText: 'Additional location details (optional)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              prefixIcon: Icon(Icons.edit_location),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32),

                    // Submit button
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _canSubmitRequest() && !_isLoading
                            ? (widget.isOnline ? _sendOnlineRequest : _sendOfflineRequest)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.isOnline ? Colors.red[600] : Colors.orange[600],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: _canSubmitRequest() && !_isLoading ? 2 : 0,
                        ),
                        child: _isLoading
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              LanguageController.get('sending_emergency_request') ?? 'Sending Emergency Request...',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(widget.isOnline ? Icons.emergency : Icons.sms),
                            SizedBox(width: 8),
                            Text(
                              widget.isOnline
                                  ? (LanguageController.get('send_emergency_request') ?? 'Send Emergency Request')
                                  : 'Send via SMS',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canSubmitRequest() {
    if (_requestType == HelpRequestType.familyMember) {
      return _selectedFamilyMember != null && _latitude != null && _longitude != null;
    }
    return _latitude != null && _longitude != null;
  }

  String _getServiceName() {
    switch (widget.type) {
      case EmergencyType.ambulance:
        return LanguageController.get('type_ambulance') ?? 'Ambulance';
      case EmergencyType.fire:
        return LanguageController.get('type_fire') ?? 'Fire';
      case EmergencyType.police:
        return LanguageController.get('type_police') ?? 'Police';
      case EmergencyType.car_accident:
        return LanguageController.get('type_car_accident') ?? 'Car Accident';
      case EmergencyType.others:
        return LanguageController.get('type_other') ?? 'Other';
    }
  }

  Future<void> _takePicture() async {
    // TODO: Implement camera functionalityc
    setState(() => _imagePath = 'dummy_path.jpg');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Photo feature will be implemented soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }


  IconData _getServiceIcon() {
    switch (widget.type) {
      case EmergencyType.ambulance:
        return Icons.local_hospital;
      case EmergencyType.fire:
        return Icons.local_fire_department;
      case EmergencyType.police:
        return Icons.local_police;
      case EmergencyType.car_accident:
        return Icons.car_crash;
      case EmergencyType.others:
        return Icons.more_horiz;
    }
  }

  Widget _buildRequestTypeCard(
      HelpRequestType type,
      IconData icon,
      String title,
      String subtitle, {
        bool enabled = true,
        Widget? trailing,
      }) {
    final isSelected = _requestType == type;
    return GestureDetector(
      onTap: enabled ? () {
        setState(() {
          _requestType = type;
          if (type != HelpRequestType.familyMember) {
            _selectedFamilyMember = null;
          }
        });
      } : null,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: enabled ? (isSelected ? Colors.blue[50] : Colors.grey[50]) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled ? (isSelected ? Colors.blue[300]! : Colors.grey[200]!) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: enabled ? (isSelected ? Colors.blue[100] : Colors.grey[200]) : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: enabled ? (isSelected ? Colors.blue[600] : Colors.grey[600]) : Colors.grey[400],
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: enabled ? (isSelected ? Colors.blue[700] : Colors.grey[800]) : Colors.grey[400],
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: enabled ? (isSelected ? Colors.blue[600] : Colors.grey[600]) : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (isSelected)
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendOnlineRequest() async {
    setState(() => _isLoading = true);

    try {
      final userData = await StorageService.getUserData();

      // Prepare request data based on request type
      Map<String, dynamic> requestData = {
        'type': widget.type.toString(),
        'request_type': _requestType.toString(),
        'details': _detailsController.text,
        'location': _locationController.text,
        'decoded_address': _decodedAddress,
        'latitude': _latitude,
        'longitude': _longitude,
        'image_path': _imagePath,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Add specific data based on request type
      switch (_requestType) {
        case HelpRequestType.me:
          requestData['user_data'] = userData;
          break;
        case HelpRequestType.other:
        // No specific user data for others
          break;
        case HelpRequestType.familyMember:
          if (_selectedFamilyMember != null) {
            requestData['family_member'] = _selectedFamilyMember!.toJson();
          }
          break;
      }

      // Create emergency request (you may need to modify EmergencyRequest model)
      final request = EmergencyRequest(
        type: widget.type,
        isForMe: _requestType == HelpRequestType.me,
        details: _detailsController.text,
        location: _locationController.text.isEmpty ? 'Current Location' : _locationController.text,
        latitude: _latitude,  // Add this
        longitude: _longitude, // Add this
        imagePath: _imagePath,
        userData: _requestType == HelpRequestType.me ? userData : null,
      );

      final result = await ApiService.sendEmergencyRequest(request);

      if (result['success'] == true) {
        _showSuccessDialog('Emergency request sent successfully!');
      } else {
        _showErrorDialog(result['message'] ?? 'Failed to send request');
      }
    } catch (e) {
      _showErrorDialog('Failed to send request: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendOfflineRequest() async {
    try {
      final userData = await StorageService.getUserData();

      Map<String, dynamic> smsData = {
        'type': _getServiceName(),
        'request_type': _getRequestTypeString(),
        'details': _detailsController.text,
        'location': _locationController.text,
        'decoded_address': _decodedAddress,
        'latitude': _latitude,
        'longitude': _longitude,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Add specific data based on request type
      switch (_requestType) {
        case HelpRequestType.me:
          if (userData != null) {
            smsData['user'] = {
              'name': '${userData['name']} ${userData['surname']}',
              'phone': userData['phone'],
              'blood_type': userData['blood_type'],
              'allergies': userData['allergies'],
            };
          }
          break;
        case HelpRequestType.other:
        // No specific user data for others
          break;
        case HelpRequestType.familyMember:
          if (_selectedFamilyMember != null) {
            smsData['family_member'] = {
              'name': _selectedFamilyMember!.name,
              'relation': _selectedFamilyMember!.relation,
              'phone': _selectedFamilyMember!.phone,
            };
          }
          break;
      }

      final smsText = 'EMERGENCY: ${jsonEncode(smsData)}';
      final uri = Uri(scheme: 'sms', path: '102', queryParameters: {'body': smsText});

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        _showSuccessDialog('SMS app opened. Please send the emergency message.');
      } else {
        _showErrorDialog('Cannot open SMS app');
      }
    } catch (e) {
      _showErrorDialog('Failed to prepare SMS: $e');
    }
  }

  String _getRequestTypeString() {
    switch (_requestType) {
      case HelpRequestType.me:
        return 'Self';
      case HelpRequestType.other:
        return 'Other Person';
      case HelpRequestType.familyMember:
        return 'Family Member: ${_selectedFamilyMember?.name ?? 'Unknown'}';
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Success'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _detailsController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
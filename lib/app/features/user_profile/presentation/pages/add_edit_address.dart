import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/widgets/custom_drop_down.dart';

import '../../../../config/widgets/custom_text_form_field.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../providers/user_profile_notifier_provider.dart';

class AddEditAddressPage extends ConsumerStatefulWidget {
  final String userId;
  final UserAddress? address;

  const AddEditAddressPage({
    super.key,
    required this.userId,
    this.address,
  });

  @override
  ConsumerState<AddEditAddressPage> createState() => _AddEditAddressPageState();
}

class _AddEditAddressPageState extends ConsumerState<AddEditAddressPage> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers & State
  late TextEditingController _addressLine1Controller;
  late TextEditingController _contactNoController;
  late TextEditingController _stateController;
  late TextEditingController _postalCodeController;

  String _addressType = 'home';
  String? _selectedCountry;
  String? _selectedCity;
  String? _selectedArea;
  bool _isDefault = false;

  // Mock Data - Replace with your data source (API call, etc.)
  final List<String> _countries = ['Bangladesh', 'India', 'USA', 'Canada', 'UK'];
  final Map<String, List<String>> _cities = {
    'Bangladesh': ['Dhaka', 'Chittagong', 'Sylhet'],
    'India': ['Mumbai', 'Delhi', 'Bangalore'],
    'USA': ['New York', 'Los Angeles', 'Chicago'],
    'Canada': ['Toronto', 'Vancouver', 'Montreal'],
    'UK': ['London', 'Manchester', 'Birmingham'],
  };
  final Map<String, List<String>> _areas = {
    'Dhaka': ['Gulshan', 'Banani', 'Dhanmondi'],
    'Chittagong': ['Agrabad', 'Nasirabad'],
    'Mumbai': ['Andheri', 'Bandra', 'Juhu'],
    'New York': ['Manhattan', 'Brooklyn', 'Queens'],
    'London': ['Westminster', 'Camden', 'Islington'],
  };

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    _addressLine1Controller = TextEditingController(text: a?.addressLine1 ?? '');
    _contactNoController = TextEditingController(text: a?.contactNo ?? '');
    _stateController = TextEditingController(text: a?.state ?? '');
    _postalCodeController = TextEditingController(text: a?.postalCode ?? '');

    if (a != null) {
      _addressType = a.type;
      _isDefault = a.isDefault;
      _selectedCountry = a.country;
      _selectedCity = a.city;
      _selectedArea = a.area;
    }
  }

  @override
  void dispose() {
    _addressLine1Controller.dispose();
    _contactNoController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newAddress = UserAddress(
        id: widget.address?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        type: _addressType,
        addressLine1: _addressLine1Controller.text,
        contactNo: _contactNoController.text,
        country: _selectedCountry!,
        state: _stateController.text,
        city: _selectedCity!,
        area: _selectedArea!,
        postalCode: _postalCodeController.text,
        isDefault: _isDefault,
      );

      final notifier = ref.read(userProfileNotifierProvider.notifier);
      if (widget.address == null) {
        notifier.addUserAddress(widget.userId, newAddress);
      } else {
        notifier.updateUserAddress(widget.userId, newAddress);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.address != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Address' : 'Add New Address'),
      ),
      // UX IMPROVEMENT: Use a BottomNavigationBar for the save button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _saveAddress,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(isEditMode ? 'Update Address' : 'Save Address', style: const TextStyle(fontSize: 16)),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Contact Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _contactNoController,
                labelText: 'Contact Number',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone,
                validator: (value) => value == null || value.isEmpty ? 'Please enter a contact number' : null,
              ),
              const SizedBox(height: 24),
              const Text('Address Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              CustomDropdown<String>(
                labelText: 'Country',
                hintText: 'Select your country',
                value: _selectedCountry,
                items: _countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCountry = value;
                    _selectedCity = null; // Reset city when country changes
                    _selectedArea = null; // Reset area
                  });
                },
                validator: (value) => value == null ? 'Please select a country' : null,
              ),
              const SizedBox(height: 16),
              CustomDropdown<String>(
                labelText: 'City',
                hintText: _selectedCountry == null ? 'Select a country first' : 'Select your city',
                value: _selectedCity,
                items: (_cities[_selectedCountry] ?? [])
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: _selectedCountry == null ? null : (value) {
                  setState(() {
                    _selectedCity = value;
                    _selectedArea = null; // Reset area when city changes
                  });
                },
                validator: (value) => value == null ? 'Please select a city' : null,
              ),
              const SizedBox(height: 16),
              CustomDropdown<String>(
                labelText: 'Area',
                hintText: _selectedCity == null ? 'Select a city first' : 'Select your area',
                value: _selectedArea,
                items: (_areas[_selectedCity] ?? [])
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: _selectedCity == null ? null : (value) {
                  setState(() => _selectedArea = value);
                },
                validator: (value) => value == null ? 'Please select an area' : null,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _addressLine1Controller,
                labelText: 'Address Line 1 (House, Road, etc.)',
                prefixIcon: Icons.location_on_outlined,
                validator: (value) => value == null || value.isEmpty ? 'Please enter an address' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      controller: _stateController,
                      labelText: 'State',
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextFormField(
                      controller: _postalCodeController,
                      labelText: 'Postal Code',
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomDropdown<String>(
                labelText: 'Address Type',
                value: _addressType,
                items: const [
                  DropdownMenuItem(value: 'home', child: Text('Home')),
                  DropdownMenuItem(value: 'office', child: Text('Office')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _addressType = value);
                  }
                },
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Set as Default Address'),
                value: _isDefault,
                onChanged: (value) => setState(() => _isDefault = value),
                activeColor: Theme.of(context).primaryColor,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 80), // Add padding at bottom for scroll clearance
            ],
          ),
        ),
      ),
    );
  }
}
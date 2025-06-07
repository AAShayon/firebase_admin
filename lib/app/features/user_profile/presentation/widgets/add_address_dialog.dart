// lib/features/user_profile/presentation/widgets/add_address_dialog.dart
import 'package:flutter/material.dart';

import '../../domain/entities/user_profile_entity.dart';

class AddAddressDialog extends StatefulWidget {
  final UserAddress? address;
  final Function(UserAddress) onSave;

  const AddAddressDialog({
    super.key,
    this.address,
    required this.onSave,
  });

  @override
  State<AddAddressDialog> createState() => _AddAddressDialogState();
}

class _AddAddressDialogState extends State<AddAddressDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late String _addressLine1;
  late String? _addressLine2;
  late String? _contactNo;
  late String _city;
  late String _state;
  late String _postalCode;
  late String _country;
  late bool _isDefault;

  @override
  void initState() {
    super.initState();
    _type = widget.address?.type ?? 'home';
    _addressLine1 = widget.address?.addressLine1 ?? '';
    _addressLine2 = widget.address?.addressLine2;
    _contactNo = widget.address?.contactNo;
    _city = widget.address?.city ?? '';
    _state = widget.address?.state ?? '';
    _postalCode = widget.address?.postalCode ?? '';
    _country = widget.address?.country ?? '';
    _isDefault = widget.address?.isDefault ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.address == null ? 'Add Address' : 'Edit Address'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'home', child: Text('Home')),
                  DropdownMenuItem(value: 'office', child: Text('Office')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (value) => setState(() => _type = value!),
                decoration: const InputDecoration(labelText: 'Address Type'),
              ),
              TextFormField(
                initialValue: _addressLine1,
                decoration: const InputDecoration(labelText: 'Address Line 1'),
                validator: (value) =>
                value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => _addressLine1 = value!,
              ),
              TextFormField(
                initialValue: _addressLine2,
                decoration: const InputDecoration(labelText: 'Address Line 2'),
                onSaved: (value) => _addressLine2 = value,
              ),
              TextFormField(
                initialValue: _contactNo,
                decoration: const InputDecoration(labelText: 'Contact No'),
                validator: (value) =>
                value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => _contactNo = value!,
              )
              ,
              TextFormField(
                initialValue: _city,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (value) =>
                value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => _city = value!,
              ),
              TextFormField(
                initialValue: _state,
                decoration: const InputDecoration(labelText: 'State/Province'),
                validator: (value) =>
                value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => _state = value!,
              ),
              TextFormField(
                initialValue: _postalCode,
                decoration: const InputDecoration(labelText: 'Postal Code'),
                validator: (value) =>
                value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => _postalCode = value!,
              ),
              TextFormField(
                initialValue: _country,
                decoration: const InputDecoration(labelText: 'Country'),
                validator: (value) =>
                value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => _country = value!,
              ),
              CheckboxListTile(
                title: const Text('Set as default address'),
                value: _isDefault,
                onChanged: (value) => setState(() => _isDefault = value ?? false),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveAddress,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final address = UserAddress(
        id: widget.address?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        type: _type,
        addressLine1: _addressLine1,
        addressLine2: _addressLine2,
        contactNo: _contactNo,
        city: _city,
        state: _state,
        postalCode: _postalCode,
        country: _country,
        isDefault: _isDefault,
      );
      widget.onSave(address);
      Navigator.pop(context);
    }
  }
}
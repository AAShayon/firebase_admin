// lib/features/user_profile/presentation/widgets/address_list_tile.dart
import 'package:flutter/material.dart';
import '../../domain/entities/user_profile_entity.dart';

class AddressListTile extends StatelessWidget {
  final UserAddress address;
  final VoidCallback onTap;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const AddressListTile({
    super.key,
    required this.address,
    required this.onTap,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(_getAddressIcon(address.type)),
        title: Text(address.type.toUpperCase()),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(address.addressLine1),
            if (address.area != null) Text(address.area!),
            Text('${address.city}, ${address.state} ${address.postalCode}'),
            Text(address.country),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (address.isDefault)
              const Icon(Icons.star, color: Colors.amber)
            else
              IconButton(
                icon: const Icon(Icons.star_border),
                onPressed: onSetDefault,
              ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  IconData _getAddressIcon(String type) {
    switch (type) {
      case 'home':
        return Icons.home;
      case 'office':
        return Icons.work;
      default:
        return Icons.location_on;
    }
  }
}
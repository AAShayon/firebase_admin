import 'package:flutter/material.dart';
import '../../../user_profile/domain/entities/user_profile_entity.dart';

class SelectableAddressTile extends StatelessWidget {
  final UserAddress address;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectableAddressTile({
    super.key,
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(address.type.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${address.addressLine1}, ${address.area}'),
                    Text('${address.city}, ${address.country}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
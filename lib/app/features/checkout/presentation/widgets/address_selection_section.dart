import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';
import '../../../user_profile/domain/entities/user_profile_entity.dart';
import 'selectable_address_tile.dart';

class AddressSelectionSection extends StatelessWidget {
  final String title;
  final List<UserAddress> addresses;
  final UserAddress? selectedAddress;
  final Function(UserAddress) onAddressSelected;
  final bool isDisabled;

  const AddressSelectionSection({
    super.key,
    required this.title,
    required this.addresses,
    required this.selectedAddress,
    required this.onAddressSelected,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isDisabled,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (addresses.isEmpty)
              OutlinedButton.icon(
                icon: const Icon(Icons.add_location_alt),
                label: const Text('Add a New Address'),
                onPressed: () => context.pushNamed(AppRoutes.addAddress),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  final address = addresses[index];
                  return SelectableAddressTile(
                    address: address,
                    isSelected: selectedAddress?.id == address.id,
                    onTap: () => onAddressSelected(address),
                  );
                },
              ),
            const SizedBox(height: 8),
            TextButton(onPressed: () => context.pushNamed(AppRoutes.addAddress), child: const Text('+ Add another address'))
          ],
        ),
      ),
    );
  }
}
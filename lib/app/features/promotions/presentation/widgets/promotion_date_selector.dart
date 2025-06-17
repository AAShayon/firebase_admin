import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PromotionDateSelector extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;

  const PromotionDateSelector({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  Future<void> _selectDate(BuildContext context, {required bool isStart}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate : endDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != (isStart ? startDate : endDate)) {
      if (isStart) {
        onStartDateChanged(picked);
      } else {
        onEndDateChanged(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd();
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Promotion Duration', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, isStart: true),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Start Date *', border: OutlineInputBorder()),
                      child: Text(dateFormat.format(startDate)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, isStart: false),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'End Date *', border: OutlineInputBorder()),
                      child: Text(dateFormat.format(endDate)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
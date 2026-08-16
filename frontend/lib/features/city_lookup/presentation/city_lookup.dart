import 'package:flutter/material.dart';
import 'package:linkup/features/city_lookup/presentation/lookup_picker.dart';

class CityLookup extends StatelessWidget {
  final Function(String) onChanged;
  final String? initialValue;
  const CityLookup({super.key, required this.onChanged, this.initialValue});

  static const List<String> _initialCities = [
    "Mumbai, Maharashtra",
    "Delhi, Delhi",
    "Bengaluru, Karnataka",
    "Jaipur, Rajasthan",
    "Agra, Uttar Pradesh",
    "Varanasi, Uttar Pradesh",
    "Kolkata, West Bengal",
    "Udaipur, Rajasthan",
    "Chennai, Tamil Nadu",
    "Hyderabad, Telangana",
    "Amritsar, Punjab",
    "Goa, Goa",
    "Kochi, Kerala",
    "Srinagar, Jammu and Kashmir",
    "Darjeeling, West Bengal",
    "Shimla, Himachal Pradesh",
    "Mysuru, Karnataka",
    "Puducherry, Puducherry",
    "Leh, Ladakh",
    "Manali, Himachal Pradesh",
    "Ahmedabad, Gujarat",
  ];

  @override
  Widget build(BuildContext context) {
    return LookupPicker(
      items: _initialCities,
      onChanged: onChanged,
      label: 'City',
      placeHolder: 'Search your hometown',
      initialValue: initialValue,
    );
  }
}

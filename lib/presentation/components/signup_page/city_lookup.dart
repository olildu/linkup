import 'package:flutter/material.dart';
import 'package:linkup/presentation/components/signup_page/lookup_picker.dart';

class CityLookup extends StatelessWidget {
  final Function(String) onChanged;
  const CityLookup({super.key, required this.onChanged});

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
    );
  }
}

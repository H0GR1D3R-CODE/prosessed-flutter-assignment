import 'package:equatable/equatable.dart';

/// The signed-in shopper.
class User extends Equatable {
  const User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.imageUrl,
    this.address,
  });

  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? imageUrl;
  final UserAddress? address;

  String get fullName => '$firstName $lastName'.trim();

  /// Up to two letters, for an avatar when there is no photo.
  String get initials {
    final letters = [
      firstName,
      lastName,
    ].where((part) => part.isNotEmpty).map((part) => part[0].toUpperCase());
    final text = letters.join();
    return text.isEmpty ? '?' : text;
  }

  @override
  List<Object?> get props => [
    id,
    username,
    firstName,
    lastName,
    email,
    phone,
    imageUrl,
    address,
  ];
}

/// Where an order would be delivered.
class UserAddress extends Equatable {
  const UserAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  /// `626 Main Street, Phoenix, Mississippi 29112, United States`
  String get oneLine => '$street, $city, $state $postalCode, $country';

  @override
  List<Object?> get props => [street, city, state, postalCode, country];
}

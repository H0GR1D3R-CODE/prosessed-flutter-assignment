import 'package:shopsphere/core/utils/json_reader.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';

/// A user as DummyJSON sends it, and as it is cached on the device.
///
/// `/auth/me` returns far more than the app needs (including fields that look like secrets in
/// the demo data). Only the handful the UI shows are read, and only those are ever stored.
class UserModel {
  const UserModel({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.image,
    this.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final address = json.mapOrNull('address');
    return UserModel(
      id: json.integer('id'),
      username: json.string('username'),
      firstName: json.string('firstName'),
      lastName: json.string('lastName'),
      email: json.string('email'),
      phone: json.stringOrNull('phone'),
      image: json.stringOrNull('image'),
      address: address == null ? null : AddressModel.fromJson(address),
    );
  }

  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? image;
  final AddressModel? address;

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'image': image,
    'address': address?.toJson(),
  };

  User toEntity() => User(
    id: id,
    username: username,
    firstName: firstName,
    lastName: lastName,
    email: email,
    phone: phone,
    imageUrl: image,
    address: address?.toEntity(),
  );
}

class AddressModel {
  const AddressModel({
    required this.address,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
    address: json.string('address'),
    city: json.string('city'),
    state: json.stringOrNull('state') ?? '',
    postalCode: json.stringOrNull('postalCode') ?? '',
    country: json.stringOrNull('country') ?? '',
  );

  final String address;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  Map<String, dynamic> toJson() => {
    'address': address,
    'city': city,
    'state': state,
    'postalCode': postalCode,
    'country': country,
  };

  UserAddress toEntity() => UserAddress(
    street: address,
    city: city,
    state: state,
    postalCode: postalCode,
    country: country,
  );
}

/// The reply to `POST /auth/login`: both tokens, with the user's fields at the top level.
class LoginResponseModel {
  const LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json.string('accessToken'),
      refreshToken: json.string('refreshToken'),
      user: UserModel.fromJson(json),
    );
  }

  final String accessToken;
  final String refreshToken;
  final UserModel user;
}

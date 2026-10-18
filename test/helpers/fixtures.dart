import 'dart:convert';
import 'dart:io';

/// Reads a JSON response saved from the real API (see test/fixtures).
Object? fixtureJson(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync());

Map<String, dynamic> fixtureMap(String name) =>
    fixtureJson(name)! as Map<String, dynamic>;

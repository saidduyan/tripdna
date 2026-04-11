import 'package:flutter/material.dart';

class TravelDnaTag {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const TravelDnaTag({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });
}

final List<TravelDnaTag> allDnaTags = [
  TravelDnaTag(
    label: 'Doğa',
    backgroundColor: const Color(0xFFE1F5EE),
    textColor: const Color(0xFF0F6E56),
  ),
  TravelDnaTag(
    label: 'Şehir kaçamağı',
    backgroundColor: const Color(0xFFE6F1FB),
    textColor: const Color(0xFF185FA5),
  ),
  TravelDnaTag(
    label: 'Kültür',
    backgroundColor: const Color(0xFFEEEDFE),
    textColor: const Color(0xFF534AB7),
  ),
  TravelDnaTag(
    label: 'Yemek turu',
    backgroundColor: const Color(0xFFFAEEDA),
    textColor: const Color(0xFF854F0B),
  ),
  TravelDnaTag(
    label: 'Sahil',
    backgroundColor: const Color(0xFFE1F5EE),
    textColor: const Color(0xFF0F6E56),
  ),
  TravelDnaTag(
    label: 'Macera',
    backgroundColor: const Color(0xFFFAECE7),
    textColor: const Color(0xFF993C1D),
  ),
  TravelDnaTag(
    label: 'Lüks',
    backgroundColor: const Color(0xFFFBEAF0),
    textColor: const Color(0xFF993556),
  ),
  TravelDnaTag(
    label: 'Bütçe gezgin',
    backgroundColor: const Color(0xFFEAF3DE),
    textColor: const Color(0xFF3B6D11),
  ),
];

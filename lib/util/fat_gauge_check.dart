import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:flutter/material.dart';

class FatGaugeCheck {
  String gender;
  int age;

  FatGaugeCheck(this.gender, this.age);

  List<GaugeSegment> segments = [];

  List<GaugeSegment> segments_Nam_18_39 = const [
    GaugeSegment(
      from: 0,
      to: 11,
      color: Color(0xFF32B5EB),
      cornerRadius: Radius.zero,
    ),
    GaugeSegment(
      from: 11,
      to: 22,
      color: Color(0xFFA3B426),
      cornerRadius: Radius.zero,
    ),
    GaugeSegment(
      from: 22,
      to: 27,
      color: Color(0xFFF7C700),
      cornerRadius: Radius.zero,
    ),
    GaugeSegment(
      from: 27,
      to: 45,
      color: Color(0xFFE88024),
      cornerRadius: Radius.zero,
    ),
  ];

  List<GaugeSegment> segments_Nam_40_59 = const [
    GaugeSegment(
      from: 0,
      to: 12,
      color: Color(0xFF32B5EB),
      cornerRadius: Radius.zero,
    ),
    GaugeSegment(
      from: 12,
      to: 23,
      color: Color(0xFFA3B426),
      cornerRadius: Radius.zero,
    ),
    GaugeSegment(
      from: 23,
      to: 28,
      color: Color(0xFFF7C700),
      cornerRadius: Radius.zero,
    ),
    GaugeSegment(
      from: 28,
      to: 45,
      color: Color(0xFFE88024),
      cornerRadius: Radius.zero,
    ),
  ];

  List<GaugeSegment> segments_Nam_60 = const [
    GaugeSegment(
      from: 0,
      to: 14,
      color: Color(0xFF32B5EB),
      cornerRadius: Radius.zero,
    ),
    GaugeSegment(
      from: 14,
      to: 25,
      color: Color(0xFFA3B426),
      cornerRadius: Radius.zero,
    ),
    GaugeSegment(
      from: 25,
      to: 30,
      color: Color(0xFFF7C700),
      cornerRadius: Radius.zero,
    ),
    GaugeSegment(
      from: 30,
      to: 45,
      color: Color(0xFFE88024),
      cornerRadius: Radius.zero,
    ),
  ];

  List<GaugeSegment> segments_Nu_18_39 = const [
    GaugeSegment(
      from: 0,
      to: 21,
      color: Color(0xFF32B5EB),
      cornerRadius: Radius.zero,
    ),
    GaugeSegment(
      from: 21,
      to: 35,
      color: Color(0xFFA3B426),
      cornerRadius: Radius.zero,
    ),
    GaugeSegment(
      from: 35,
      to: 40,
      color: Color(0xFFF7C700),
      cornerRadius: Radius.zero,
    ),
    GaugeSegment(
      from: 40,
      to: 45,
      color: Color(0xFFE88024),
      cornerRadius: Radius.zero,
    ),
  ];

  final List<GaugeSegment> segments_Nu_40_59 = const [
    GaugeSegment(
      from: 0,
      to: 22,
      color: Color(0xFF32B5EB),
      cornerRadius: Radius.zero,
    ),
    GaugeSegment(
      from: 22,
      to: 36,
      color: Color(0xFFA3B426),
      cornerRadius: Radius.zero,
    ),
    GaugeSegment(
      from: 36,
      to: 41,
      color: Color(0xFFF7C700),
      cornerRadius: Radius.zero,
    ),
    GaugeSegment(
      from: 41,
      to: 45,
      color: Color(0xFFE88024),
      cornerRadius: Radius.zero,
    ),
  ];

  List<GaugeSegment> segments_Nu_60 = const [
    GaugeSegment(
      from: 0,
      to: 23,
      color: Color(0xFF32B5EB),
      cornerRadius: Radius.zero,
    ),
    GaugeSegment(
      from: 23,
      to: 30,
      color: Color(0xFFA3B426),
      cornerRadius: Radius.zero,
    ),
    GaugeSegment(
      from: 30,
      to: 37,
      color: Color(0xFFF7C700),
      cornerRadius: Radius.zero,
    ),
    GaugeSegment(
      from: 37,
      to: 45,
      color: Color(0xFFE88024),
      cornerRadius: Radius.zero,
    ),
  ];

  void checkSegment() {
    if (gender == 'Nam') {
      if (age >= 18 && age <= 39) {
        segments = segments_Nam_18_39;
      } else if (age >= 40 && age <= 59) {
        segments = segments_Nam_40_59;
      } else if (age >= 60) {
        segments = segments_Nam_60;
      }
    } else if (gender == 'Nữ') {
      if (age >= 18 && age <= 39) {
        segments = segments_Nu_18_39;
      } else if (age >= 40 && age <= 59) {
        segments = segments_Nu_40_59;
      } else if (age >= 60) {
        segments = segments_Nu_60;
      }
    }
  }

  List<GaugeSegment> fatGagugeSegment() {
    checkSegment();
    return segments;
  }
}
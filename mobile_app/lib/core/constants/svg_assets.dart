import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgAssets {
  static const String sosSiren = '''
  <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M12 2C6.48 2 2 6.48 2 12C2 17.52 6.48 22 12 22C17.52 22 22 17.52 22 12C22 6.48 17.52 2 12 2ZM12 20C7.59 20 4 16.41 4 12C4 7.59 7.59 4 12 4C16.41 4 20 7.59 20 12C20 16.41 16.41 20 12 20Z" fill="currentColor"/>
    <path d="M11 7H13V13H11V7ZM11 15H13V17H11V15Z" fill="currentColor"/>
  </svg>
  ''';

  static const String ambulance = '''
  <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M19 12H18V8C18 6.9 17.1 6 16 6H3C1.9 6 1 6.9 1 8V16C1 17.1 1.9 18 3 18H4C4 19.66 5.34 21 7 21C8.66 21 10 19.66 10 18H14C14 19.66 15.34 21 17 21C18.66 21 20 19.66 20 18H21C22.1 18 23 17.1 23 16V14L19 12ZM7 19.5C5.62 19.5 4.5 18.38 4.5 17C4.5 15.62 5.62 14.5 7 14.5C8.38 14.5 9.5 15.62 9.5 17C9.5 18.38 8.38 19.5 7 19.5ZM17 19.5C15.62 19.5 14.5 18.38 14.5 17C14.5 15.62 15.62 14.5 17 14.5C18.38 14.5 19.5 15.62 19.5 17C19.5 18.38 18.38 19.5 17 19.5ZM14 12H10V10H14V12ZM9 9H7V11H5V9H3V7H5V5H7V7H9V9Z" fill="currentColor"/>
  </svg>
  ''';

  static const String police = '''
  <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M12 1L3 5V11C3 16.55 6.84 21.74 12 23C17.16 21.74 21 16.55 21 11V5L12 1ZM12 11.99H19C18.47 16.11 15.72 19.78 12 20.93V12H5V6.3L12 3.19V11.99Z" fill="currentColor"/>
  </svg>
  ''';

  static const String fireService = '''
  <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M12 2C11.5 6 8 8 8 12C8 14.21 9.79 16 12 16C14.21 16 16 14.21 16 12C16 8 12.5 6 12 2ZM12 22C6.48 22 2 17.52 2 12C2 7.74 4.67 4.1 8.5 2.65C7.5 5 7.5 7.5 9 10C10.5 12.5 13 13 13 16C13 16.55 12.55 17 12 17C11.45 17 11 16.55 11 16C11 14.5 9 13.5 9 13.5C8 16.5 10 19 12 19C14.5 19 17 17 17 13C17 10 15 8 15 8C19 10 22 13 22 17C22 19.76 17.52 22 12 22Z" fill="currentColor"/>
  </svg>
  ''';

  static const String hospital = '''
  <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M19 3H5C3.9 3 3 3.9 3 5V19C3 20.1 3.9 21 5 21H19C20.1 21 21 20.1 21 19V5C21 3.9 20.1 3 19 3ZM18 14H14V18H10V14H6V10H10V6H14V10H18V14Z" fill="currentColor"/>
  </svg>
  ''';

  static const String poisonControl = '''
  <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M12 2L1 21H23L12 2ZM12 6L19.53 19H4.47L12 6ZM11 10V14H13V10H11ZM11 16V18H13V16H11Z" fill="currentColor"/>
  </svg>
  ''';

  static const String medicalBadge = '''
  <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M20 4H4C2.9 4 2 4.9 2 6V18C2 19.1 2.9 20 4 20H20C21.1 20 22 19.1 22 18V6C22 4.9 21.1 4 20 4ZM20 18H4V6H20V18ZM6 10H10V14H6V10ZM12 9H18V11H12V9ZM12 13H16V15H12V13Z" fill="currentColor"/>
  </svg>
  ''';

  static const String phoneCall = '''
  <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M6.62 10.79C8.06 13.62 10.38 15.94 13.21 17.38L15.41 15.18C15.69 14.9 16.08 14.82 16.43 14.93C17.55 15.3 18.75 15.5 20 15.5C20.55 15.5 21 15.95 21 16.5V20C21 20.55 20.55 21 20 21C10.61 21 3 13.39 3 4C3 3.45 3.45 3 4 3H7.5C8.05 3 8.5 3.45 8.5 4C8.5 5.25 8.7 6.45 9.07 7.57C9.18 7.92 9.1 8.31 8.82 8.59L6.62 10.79Z" fill="currentColor"/>
  </svg>
  ''';

  static const String bloodDrop = '''
  <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M12 2.69L6.71 8.87C4.94 10.94 4 13.5 4 16C4 20.42 7.58 24 12 24C16.42 24 20 20.42 20 16C20 13.5 19.06 10.94 17.29 8.87L12 2.69ZM12 21.5C8.97 21.5 6.5 19.03 6.5 16C6.5 14.15 7.21 12.25 8.56 10.66L12 6.64L15.44 10.67C16.79 12.25 17.5 14.15 17.5 16C17.5 19.03 15.03 21.5 12 21.5Z" fill="currentColor"/>
  </svg>
  ''';

  static const String locationPin = '''
  <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M12 2C8.13 2 5 5.13 5 9C5 14.25 12 22 12 22C12 22 19 14.25 19 9C19 5.13 15.87 2 12 2ZM12 11.5C10.62 11.5 9.5 10.38 9.5 9C9.5 7.62 10.62 6.5 12 6.5C13.38 6.5 14.5 7.62 14.5 9C14.5 10.38 13.38 11.5 12 11.5Z" fill="currentColor"/>
  </svg>
  ''';

  static Widget icon(String svgRaw, {double width = 24, double height = 24, Color? color}) {
    return SvgPicture.string(
      svgRaw,
      width: width,
      height: height,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }
}

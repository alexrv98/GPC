import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TermsViewModel extends ChangeNotifier {
  bool _hasAcceptedTerms = false;

  bool get hasAcceptedTerms => _hasAcceptedTerms;

  Future<void> checkTermsAccepted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _hasAcceptedTerms = prefs.getBool('hasAcceptedTerms') ?? false;
    notifyListeners();
  }

  Future<void> acceptTerms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasAcceptedTerms', true);
    _hasAcceptedTerms = true;
    notifyListeners();
    
  }
  
}

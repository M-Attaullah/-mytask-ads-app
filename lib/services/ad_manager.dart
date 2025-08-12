import 'package:firebase_database/firebase_database.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

class AdManager {
  static final AdManager instance = AdManager._internal();
  AdManager._internal();

  String? bannerAdUnitId;
  String? interstitialAdUnitId;
  String? appOpenAdUnitId;

  InterstitialAd? _interstitialAd;
  AppOpenAd? _appOpenAd;
  bool _isAppOpenAdAvailable = false;

  Future<void> init() async {
    final db = FirebaseDatabase.instance.ref('admob');
    final snapshot = await db.get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      bannerAdUnitId = data['banner'] as String?;
      interstitialAdUnitId = data['interstitial'] as String?;
      appOpenAdUnitId = data['app_open'] as String?;
    }
    _preloadInterstitial();
    _preloadAppOpen();
  }

  BannerAd? createBannerAd() {
    if (bannerAdUnitId == null) return null;
    return BannerAd(
      adUnitId: bannerAdUnitId!,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    );
  }

  void _preloadInterstitial() {
    if (interstitialAdUnitId == null) return;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId!,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => _interstitialAd = null,
      ),
    );
  }

  void _preloadAppOpen() {
    if (appOpenAdUnitId == null) return;
    AppOpenAd.load(
      adUnitId: appOpenAdUnitId!,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAppOpenAdAvailable = true;
        },
        onAdFailedToLoad: (error) {
          _appOpenAd = null;
          _isAppOpenAdAvailable = false;
        },
      ),
      orientation: AppOpenAd.orientationPortrait,
    );
  }

  void showInterstitialBeforeNavigate(VoidCallback onNavigate) {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _preloadInterstitial();
          onNavigate();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _preloadInterstitial();
          onNavigate();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      onNavigate();
      _preloadInterstitial();
    }
  }

  void showAppOpenIfAvailable(VoidCallback onContinue) {
    if (_isAppOpenAdAvailable && _appOpenAd != null) {
      _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isAppOpenAdAvailable = false;
          _preloadAppOpen();
          onContinue();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isAppOpenAdAvailable = false;
          _preloadAppOpen();
          onContinue();
        },
      );
      _appOpenAd!.show();
      _appOpenAd = null;
      _isAppOpenAdAvailable = false;
    } else {
      onContinue();
      _preloadAppOpen();
    }
  }
}

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
    debugPrint('AdManager.init() called');
    // Use CORRECT Google test ad unit IDs 
    bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // Test banner ID
    interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712'; // Test interstitial ID  
    appOpenAdUnitId = 'ca-app-pub-3940256099942544/9257395921'; // CORRECTED App open ID
    
    debugPrint('Set ad unit IDs:');
    debugPrint('Banner: $bannerAdUnitId');
    debugPrint('Interstitial: $interstitialAdUnitId'); 
    debugPrint('App Open: $appOpenAdUnitId');
    
    try {
      // Try to load from Firebase, but don't block if it fails
      final db = FirebaseDatabase.instance.ref('admob');
      final snapshot = await db.get().timeout(const Duration(seconds: 3));
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        bannerAdUnitId = data['banner'] as String? ?? bannerAdUnitId;
        interstitialAdUnitId = data['interstitial'] as String? ?? interstitialAdUnitId;
        appOpenAdUnitId = data['app_open'] as String? ?? appOpenAdUnitId;
        debugPrint('Updated ad IDs from Firebase');
      }
    } catch (e) {
      debugPrint('Firebase failed, using test ad IDs: $e');
    }
    
    try {
      debugPrint('Starting ad preloading...');
      _preloadInterstitial();
      _preloadAppOpen();
      debugPrint('Ad preloading initiated');
    } catch (e) {
      debugPrint('Error during ad preloading: $e');
    }
  }

  BannerAd? createBannerAd({BannerAdListener? listener}) {
    if (bannerAdUnitId == null) return null;
    return BannerAd(
      adUnitId: bannerAdUnitId!,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: listener ?? const BannerAdListener(),
    );
  }

  void _preloadInterstitial() {
    debugPrint('_preloadInterstitial called');
    if (interstitialAdUnitId == null) {
      debugPrint('interstitialAdUnitId is null, cannot load ad');
      return;
    }
    debugPrint('Loading interstitial ad with ID: $interstitialAdUnitId');
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId!,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Interstitial ad loaded successfully');
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  void _preloadAppOpen() {
    debugPrint('_preloadAppOpen called');
    if (appOpenAdUnitId == null) {
      debugPrint('appOpenAdUnitId is null, cannot load ad');
      return;
    }
    debugPrint('Loading app open ad with ID: $appOpenAdUnitId');
    AppOpenAd.load(
      adUnitId: appOpenAdUnitId!,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('App open ad loaded successfully');
          _appOpenAd = ad;
          _isAppOpenAdAvailable = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint('App open ad failed to load: $error');
          _appOpenAd = null;
          _isAppOpenAdAvailable = false;
        },
      ),
    );
  }

  void showInterstitialBeforeNavigate(VoidCallback onNavigate) {
    debugPrint('showInterstitialBeforeNavigate called');
    debugPrint('_interstitialAd is null: ${_interstitialAd == null}');
    
    if (_interstitialAd != null) {
      debugPrint('Showing interstitial ad...');
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('Interstitial ad dismissed');
          ad.dispose();
          _preloadInterstitial();
          onNavigate();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('Interstitial ad failed to show: $error');
          ad.dispose();
          _preloadInterstitial();
          onNavigate();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      debugPrint('No interstitial ad available, navigating directly...');
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

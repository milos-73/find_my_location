import 'dart:ui';

import 'package:find_me/markers_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'ad_helper_test.dart';
import 'ad_helper.dart';
import 'category_provider.dart';
import 'markers_category_model.dart';

class EditCategoryRecord extends StatefulWidget {
  final int index;
  final int categoryKey;
  final MyMarkersCategory category;

  EditCategoryRecord({Key? key, required this.index, required this.category, required this.categoryKey}) : super(key: key);

  @override
  State<EditCategoryRecord> createState() => _EditCategoryRecordState();
}

const int maxFailedLoadAttempts = 3;

class _EditCategoryRecordState extends State<EditCategoryRecord> {

  bool isLoading = false;
  late Box<MyMarkersCategory> myCategoryBox;


  // TODO: Add _interstitialAd
  InterstitialAd? _interstitialAd;
  int _interstitialLoadAttempts = 0;

  TextEditingController categoryTitleController = TextEditingController();
  TextEditingController categoryDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState((){isLoading = true;});
    myCategoryBox = Hive.box('myMarkersCategoryBox');

    //_createInterstitialAdCancel();
    //_createInterstitialAdSave();

    setState((){categoryTitleController.text = widget.category.markerCategoryTitle!;});
    setState((){categoryDescriptionController.text = '${widget.category.markerCategoryDescription}';});
      }

  void _createInterstitialAdSave() {
    InterstitialAd.load(
      adUnitId: AdHelper.editSave,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _interstitialLoadAttempts = 0;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialLoadAttempts += 1;
          _interstitialAd = null;
          if (_interstitialLoadAttempts <= maxFailedLoadAttempts) {
            _createInterstitialAdSave();
          }
        },
      ),
    );
  }

  void _createInterstitialAdCancel() {
    InterstitialAd.load(
      adUnitId: AdHelper.editSave,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _interstitialLoadAttempts = 0;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialLoadAttempts += 1;
          _interstitialAd = null;
          if (_interstitialLoadAttempts <= maxFailedLoadAttempts) {
            _createInterstitialAdCancel();
          }
        },
      ),
    );
  }

  void _showInterstitialAdSave() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _createInterstitialAdSave();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          _createInterstitialAdSave();
        },
      );
      _interstitialAd!.show();
    }
  }

  void _showInterstitialAdCancel() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _createInterstitialAdCancel();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          _createInterstitialAdCancel();
        },
      );
      _interstitialAd!.show();
    }
  }

  @override
  Widget build(BuildContext context) {



    return Scaffold(backgroundColor: HexColor('#d8ded5'),
      floatingActionButton: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 45),
            child: FloatingActionButton.extended(onPressed: () {
              //_showInterstitialAdCancel();
              Navigator.pop(context);
            }, label: Row(children: const [FaIcon(FontAwesomeIcons.x), SizedBox(width: 5,),Text('Cancel')],),backgroundColor: Colors.red,splashColor: HexColor('#D99E6A'),heroTag: 'cancelButton',),
          ),
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FloatingActionButton.extended(onPressed: () {
              final newCategory = MyMarkersCategory(markerCategoryTitle: categoryTitleController.text, markerCategoryDescription: categoryDescriptionController.text);
              //print('WIDGET EDIT CATEGORY KEY: ${widget.categoryKey}');
              print('WIDGET NEW CATEGORY TITLE: ${newCategory.markerCategoryTitle}');

             // _showInterstitialAdSave();
              Provider.of<CategoryProvider>(context, listen: false).updateCategoryList(newCategory, widget.categoryKey);
              myCategoryBox.putAt(widget.index, newCategory);
              //myCategoryBox.put(widget.categoryKey, newCategory);
              Provider.of<CategoryProvider>(context, listen: false).addToCategoryList(newCategory);
              Navigator.pop(context);
            }, label: Row(children: const [FaIcon(FontAwesomeIcons.floppyDisk), SizedBox(width: 5,),Text('Save')],),backgroundColor: HexColor('#0468BF'),splashColor: HexColor('#D99E6A'),heroTag: 'saveButton',),
          ),

        ],
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(decoration: InputDecoration(filled: true,fillColor: HexColor('#b1bdab').withOpacity(0.4),focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20),borderSide: BorderSide(color: HexColor('#D99E6A'))),border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),labelText: 'Category Title', labelStyle: TextStyle(color: HexColor('#8C4332'),fontSize: 20,fontWeight: FontWeight.w600),hintStyle: const TextStyle(color: Colors.white70)),controller: categoryTitleController,),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(maxLines: 6,minLines:1, decoration: InputDecoration(filled: true,fillColor: HexColor('#b1bdab').withOpacity(0.4),focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20),borderSide: BorderSide(color: HexColor('#D99E6A'))),border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),labelText: 'Category Description', labelStyle: TextStyle(color: HexColor('#8C4332'),fontSize: 20,fontWeight: FontWeight.w600),hintStyle: const TextStyle(color: Colors.white70)),controller: categoryDescriptionController,),
          ),
        ],),
      )
    );
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd?.dispose();
  }

}

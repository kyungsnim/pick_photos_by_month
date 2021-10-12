import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

class MakeUpImagesPage extends StatefulWidget {
  @override
  _MakeUpImagesPageState createState() => _MakeUpImagesPageState();
}

class _MakeUpImagesPageState extends State<MakeUpImagesPage> {
  bool? _isLoading;
  DateTime _babyBirthday = DateTime.now();
  List<File> fileImageArray = [];
  List<String> f = [];
  var imagePath = '/storage/emulated/0/DCIM';
  String myImagePath = "";
  List<AssetPathEntity> targetPathList = []; // 복사될 타겟 앨범
  AssetPathEntity? target;

  List<AssetPathEntity>? albums;
  List<AssetEntity>? media;
  List<AssetPathEntity>? saveBabyAlbums = [];

  List<String> deleteId = []; // 복사 후 삭제할 리스트

  /// image_picker
  // final ImagePicker _picker = ImagePicker();
  // List<XFile>? resultList;

  /// photo_manager
  // List<AssetPathEntity>? resultList;

  /// multi_image_picker2
  List<Asset> resultList = [];

  /// wechat_assets_picker
  // List<AssetEntity> resultListWithWechat = [];

  TextEditingController _babyNameEditingController = TextEditingController();
  String? _babyName;

  var _index; // 사진 스와이프 컨트롤용 인덱스

  String? lastSelectDateByString;

  // AdmobBannerSize bannerSize = AdmobBannerSize.BANNER;
  // var bannerId = Platform.isIOS
  //     ? 'ca-app-pub-6109556651195087/4177051916'
  //     : 'ca-app-pub-6109556651195087/1937901387';
  BannerAd? banner;
  InterstitialAd? interstitial;
  String iOSBannerId = 'ca-app-pub-6109556651195087/3422211080';
  String iOSInterstitialId = 'ca-app-pub-6109556651195087/1429299107';
  String iOSOverlayId = 'ca-app-pub-6109556651195087/6048374429';

  GlobalKey<ScaffoldState> scaffoldState = GlobalKey();

  var enLocale = Locale('en', 'US');
  var koLocale = Locale('kr', 'KO');
  var nowLocale = Locale('en', 'US');

  @override
  void initState() {
    super.initState();

    // readyForAdmob();
    fetchMedia();

    banner = BannerAd(
      size: AdSize.banner,
      adUnitId: iOSBannerId, //iOSTestId : androidTestId,
      listener: BannerAdListener(),
      request: AdRequest(),
    )
      ..load();

    InterstitialAd.load(
        adUnitId: iOSInterstitialId,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            // Keep a reference to the ad so you can show it later.
            this.interstitial = ad;

            if (DateTime
                .now()
                .second % 5 == 0) {
              interstitial!.show();
            }
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error');
          },
        ));

    setState(() {
      _isLoading = false;
      _index = 0;
      _babyBirthday = DateTime.now();
    });

    // 복사될 타겟 앨범 셋팅
    PhotoManager.getAssetPathList(hasAll: true, type: RequestType.common)
        .then((value) {
      this.targetPathList = value;
      setState(() {});
    });
  }

  // readyForAdmob() async {
  //   // Run this before displaying any ad.
  //   await Admob.requestTrackingAuthorization();
  //   bannerSize = AdmobBannerSize.BANNER;
  // }

  @override
  void dispose() {
    super.dispose();
    PhotoManager.clearFileCache();

    /// ads
    if(banner != null) {
      banner!.dispose();
    }
    if(interstitial != null) {
      interstitial!.dispose();
    }

    _babyNameEditingController.dispose();
  }

  babyNameInputArea(hintText) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.yellow.withOpacity(0.5), width: 5),
          borderRadius: BorderRadius.circular(10),
          color: Colors.yellow.shade600,
          boxShadow: const [
            BoxShadow(
                offset: Offset(1, 1), blurRadius: 5, color: Colors.white24)
          ]),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: TextFormField(
          controller: _babyNameEditingController,
          decoration: InputDecoration(
              border: InputBorder.none,
              icon: Icon(Icons.person, color: Colors.indigo),
              hintText: hintText,
              hintStyle: TextStyle(fontSize: 15)),
          onChanged: (val) {
            _babyName = val;
          },
        ),
      ),
    );
  }

  babyNameInputAreaWithListTile() {
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width * 1,
      height: MediaQuery.of(context).size.height * 0.06,
      child: Stack(children: [
        Container(
          decoration: const BoxDecoration(
              border: Border.symmetric(
                  horizontal: BorderSide(color: Colors.black54, width: 0.5))),
          width: MediaQuery.of(context).size.width * 1,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            style: const TextStyle(fontFamily: 'SLEIGothic', color: Colors.black54),
            controller: _babyNameEditingController,
            cursorColor: Colors.black,
            validator: (val) {
              if (val!.isEmpty) {
                return '내용을 입력하세요';
              } else {
                return null;
              }
            },
            decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '아이의 이름을 입력하세요.',
                hintStyle: TextStyle(
                    fontFamily: 'SLEIGothic',
                    fontSize: 15,
                    color: Colors.lightBlue)),
            onChanged: (val) {
              setState(() {
                _babyName = val;
              });
            },
          ),
        ),
      ]),
    );
  }

  babyBirthDaySelectArea() {
    return InkWell(
      onTap: () async {
        DateTime? picked = (await showDatePicker(
            context: context,
            initialDate: _babyBirthday,
            firstDate: DateTime(_babyBirthday.year - 50),
            lastDate: DateTime(_babyBirthday.year + 50),
            builder: (BuildContext context, Widget? child) {
              return Theme(
                data: ThemeData.light().copyWith(
                  colorScheme: ColorScheme.light().copyWith(
                    primary: Colors.lightBlue,
                  ),
                  buttonTheme:
                      const ButtonThemeData(textTheme: ButtonTextTheme.primary),
                ),
                child: child!,
              );
            },
            confirmText: '확인',
            cancelText: '취소'));

        setState(() {
          _babyBirthday = picked ?? DateTime.now();
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 1,
        height: MediaQuery.of(context).size.height * 0.08,
        decoration: const BoxDecoration(
            border: Border.symmetric(
                horizontal: BorderSide(color: Colors.black54, width: 0.5))),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: ListTile(
                title: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.lightBlue),
                    const SizedBox(width: 15),
                    Text(
                      "${_babyBirthday.year}-${_babyBirthday.month}-${_babyBirthday.day}",
                      style: const TextStyle(
                          fontFamily: 'SLEIGothic', color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  inputAreaTitle(titleText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(titleText,
              style: const TextStyle(
                  fontFamily: 'SLEIGothic',
                  color: Colors.lightBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _isLoading!
            ? Center(
                child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                    height: MediaQuery.of(context).size.width * 0.1,
                    child: const LoadingIndicator(
                      indicatorType: Indicator.lineScalePulseOut,
                      colors: [Colors.lightBlue],
                    )))
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ListView(
                    children: [
                      CarouselSlider(
                        options: CarouselOptions(
                            height: MediaQuery.of(context).size.width * 1,
                            viewportFraction: 1,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _index = index;
                              });
                            }),
                        // carouselController: _carouselController,
                        items: [1, 2].map((i) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                  child: Image.asset(
                                    nowLocale == koLocale
                                        ? 'assets/images/kr_$i.png'
                                        : 'assets/images/us_$i.png',
                                    fit: BoxFit.cover,
                                  ));
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: _index == 0
                                    ? Colors.lightBlue
                                    : Colors.grey),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: _index == 0
                                    ? Colors.grey
                                    : Colors.lightBlue),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      inputAreaTitle('Baby`s birthday'.tr),
                      babyBirthDaySelectArea(),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 50.0,
                        child: AdWidget(
                          ad: banner!,
                        ),
                      ),
                      // Container(
                      //     color: Colors.white,
                      //     height: 50,
                      //     child: AdmobBanner(
                      //         adUnitId: bannerId, //AdmobBanner.testAdUnitId,
                      //         adSize: bannerSize,
                      //         listener: (AdmobAdEvent event,
                      //             Map<String, dynamic> args) {
                      //           handleEvent(event, args, 'Banner');
                      //         },
                      //         onBannerCreated:
                      //             (AdmobBannerController controller) {})),
                      // BabyImage(),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            flex: 1,
                            child: InkWell(
                              onTap: () async {
                                /// 아이 생년월일 등록 안했으면 그것부터 해줘야 함
                                getBabyMonthImageWithoutBabyAlbum();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: Colors.lightBlue,
                                ),
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.height * 0.06,
                                child: Center(
                                    child: Text('Choose photos'.tr,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontFamily: 'SLEIGothic'))),
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          if (nowLocale == enLocale) {
                            setState(() {
                              nowLocale = koLocale;
                            });
                          } else {
                            setState(() {
                              nowLocale = enLocale;
                            });
                          }
                          Get.updateLocale(nowLocale);
                        },
                        child: Text('Change language'.tr),
                      ),
                    ],
                  ),
                ),
              ));
  }

  fetchMedia() async {
    var result = await PhotoManager.requestPermission();
    if (result) {
      albums = await PhotoManager.getAssetPathList(onlyAll: true);
    } else {
      print('권한없음');
    }
    media = await albums![0].getAssetListPaged(0, 50000);
  }

  Future<File> imageToFile(String imageName) async {
    var bytes = await rootBundle.load('$imageName');
    String tempPath = (await getTemporaryDirectory()).path;
    File file = File('$tempPath/profile.png');
    await file.writeAsBytes(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
    return file;
  }

  getBabyMonthImageWithoutBabyAlbum() async {
    setState(() {
      _isLoading = true;
    });
    // 사진 고르기
    try {
      /// with photo_manager
      // resultList = await PhotoManager.getAssetPathList();
      /// with multi_image_picker2
      resultList = await MultiImagePicker.pickImages(
        maxImages: 500,
      );
      /// with image_picker
      // resultList = await _picker.pickMultiImage();

      /// with wechat_assets_picker
      // resultListWithWechat = (await AssetPicker.pickAssets(
      //   context,
      //   maxAssets: 9,
      //   requestType: RequestType.image,
      // ))!;
    } catch (e) {
      print('error : $e');

      setState(() {
        _isLoading = false;
      });
    }

    var existBabyAlbum = false;
    var babyAlbumIndex = 0;
    var movedImageCount = 0;
    var androidNewAlbum;
    // 아기 이름 앨범 없으면 만들어 줄 것
    if (Platform.isAndroid) {
      androidNewAlbum = await makeAndroidAlbum(_babyName);

      // 복사될 타겟 앨범 셋팅
      PhotoManager.getAssetPathList(
              hasAll: true, type: RequestType.all, onlyAll: true)
          .then((value) {
        this.targetPathList = value;
        setState(() {});
      });
    }

    // 만일 4, 6, 7개월때 사진을 골랐다면...
    // 사용자가 실제로 고른 사진 목록으로 기존 앨범 사진 검색
    for (int i = 0; i < resultList.length; i++) {
    // for (int i = 0; i < resultListWithWechat.length; i++) {
      // 아이폰의 경우 identifier로 찾을 수 있고 안드로이드의 경우 filename으로 매칭시킬 수 있다.
      for (var asset in media!) {
        // Platform.isIOS ? print('iOS id : ${asset.id}') : print('android title : ${asset.title}');

        /// image_picker_4C6CE1DB-26C0-4AC3-9719-68CDFAFEFBF0-10172-00000791764B077F.jpg
        ///              D8D11E3C-C26D-4094-B595-DAD71F8085CE/L0/001
        // 아이폰사진의 경우 내가 고른사진의 id와 앨범의 id가 일치한다면
        // var imageId = resultList![i].path.split("/").last;
        // var assetId = asset.id.split("/").first;
        // print('imageId: $imageId | assetId: $assetId');
        // if(assetId.contains("8A973910")) {
        //   print(1234);
        // }
        if (Platform.isIOS
            // ? imageId.contains(assetId) // identifier
            ? resultList[i].identifier == asset.id // identifier
            // ? resultListWithWechat[i].id == asset.id // identifier
            : resultList[i].name == asset.title) {
          // 해당 사진의 개월수 계산
          var babyMonths =
              (asset.createDateTime.difference(_babyBirthday).inDays / 30)
                  .floor();

          AssetEntity tmpAsset = AssetEntity(id: asset.id, typeInt: asset.typeInt, width: asset.width, height: asset.height);
          // AssetEntity imageEntity = await PhotoManager.editor.saveImageWithPath(asset.);

          var existAlbum = false;

          // iOS
          if (Platform.isIOS) {

            // 기존 폴더 돌면서 아기 개월수 폴더 있는지 체크
            for (int j = 0; j < targetPathList.length; j++) {
              if (targetPathList[j].name == "$babyMonths month" ||
                  targetPathList[j].name == "$babyMonths month(s)") {
                // 해당 개월의 폴더 안에 사진 이동
                PhotoManager.editor
                    .copyAssetToPath(
                        asset: tmpAsset, pathEntity: targetPathList[j])
                    .then((_) async {
                  movedImageCount++;

                  if (resultList.length == movedImageCount) {
                  // if (resultListWithWechat.length == movedImageCount) {
                    // setState(() {
                    //   _isLoading = false;
                    // });
                    // showToast("${resultList.length}개 이미지 이동 완료");

                    var yearOfToday = DateTime.now().year > 10
                        ? '${DateTime.now().year}'
                        : '0${DateTime.now().year}';
                    var monthOfToday = DateTime.now().month > 10
                        ? '${DateTime.now().month}'
                        : '0${DateTime.now().month}';
                    var dayOfToday = DateTime.now().day > 10
                        ? '${DateTime.now().day}'
                        : '0${DateTime.now().day}';
                    var todayByString =
                        '$yearOfToday/$monthOfToday/$dayOfToday';
                    // await FlutterSecureStorage().write(key: 'lastSelect', value: todayByString, );

                    // FirebaseFirestore.instance.collection('users').doc(currentUser.id).update({
                    //   'lastSelect': todayByString
                    // });
                  }
                });
                existAlbum = true;
              }
            }

            // 모든 앨범 찾아봤는데 해당 개월수의 앨범이 없는 경우 앨범 만들어준 후에 파일 복사해야 함
            if (!existAlbum) {
              if (babyMonths == 0 || babyMonths == 1)
                targetPathList.add((await PhotoManager.editor.iOS
                    .createAlbum("$babyMonths month"))!);
              else
                targetPathList.add((await PhotoManager.editor.iOS
                    .createAlbum("$babyMonths month(s)"))!);

              // 바로 위에서 추가한 앨범에 개월수 사진 넣어주기
              PhotoManager.editor
                  .copyAssetToPath(
                      asset: tmpAsset,
                      pathEntity: targetPathList[targetPathList.length - 1])
                  .then((_) {
                movedImageCount++;
              });
            }
            // Android
          } else if (Platform.isAndroid) {
            // for (int i = 0; i <= 20; i++) {
            //   var tmpPath = i == 0 || i == 1
            //       ? '${androidNewAlbum.path}/$i month'
            //       : '${androidNewAlbum.path}/$i month(s)';
            //   if (Directory(tmpPath).existsSync()) {
            //   } else {
            //     Directory(tmpPath).create().then((newPath) {});
            //   }
            // }
            File? moveFile = await asset.file;
            var fileName = moveFile!.path.split('/').last;
            movedImageCount++;
            // await moveFile.delete();
          }
        }
      }
    }
    setState(() {
      _isLoading = false;
    });
    Get.snackbar("사진 정리", "선택한 ${resultList.length}개 중 $movedImageCount개 이미지 이동 완료");
    // Get.snackbar("사진 정리", "선택한 ${resultListWithWechat.length}개 중 $movedImageCount개 이미지 이동 완료");
    // showToast("${resultList.length}개 이미지 이동 완료");
  }

  // void handleEvent(
  //     AdmobAdEvent event, Map<String, dynamic> args, String adType) {
  //   switch (event) {
  //     case AdmobAdEvent.loaded:
  //       showSnackBar('New Admob $adType Ad loaded!');
  //       break;
  //     case AdmobAdEvent.opened:
  //       showSnackBar('Admob $adType Ad opened!');
  //       break;
  //     case AdmobAdEvent.closed:
  //       showSnackBar('Admob $adType Ad closed!');
  //       break;
  //     case AdmobAdEvent.failedToLoad:
  //       showSnackBar('Admob $adType failed to load. :(');
  //       break;
  //     case AdmobAdEvent.rewarded:
  //       showDialog(
  //         context: scaffoldState.currentContext!,
  //         builder: (BuildContext context) {
  //           return WillPopScope(
  //             child: AlertDialog(
  //               content: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: <Widget>[
  //                   Text('Reward callback fired. Thanks Andrew!'),
  //                   Text('Type: ${args['type']}'),
  //                   Text('Amount: ${args['amount']}'),
  //                 ],
  //               ),
  //             ),
  //             onWillPop: () async {
  //               scaffoldState.currentState!.hideCurrentSnackBar();
  //               return true;
  //             },
  //           );
  //         },
  //       );
  //       break;
  //     default:
  //   }
  // }

  void showSnackBar(String content) {
    scaffoldState.currentState!.showSnackBar(
      SnackBar(
        content: Text(content),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  Future<dynamic> makeAndroidAlbum(var albumName) async {
    myImagePath = '$imagePath/$albumName';
    return await Directory(myImagePath).create();
  }
}

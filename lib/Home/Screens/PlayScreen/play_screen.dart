import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screen_wake/flutter_screen_wake.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';
import 'package:zineplayer/Home/Screens/HomeScreen/folderList/colors_and_texts.dart';
import 'package:zineplayer/Home/Screen%20functions/list_functions.dart';
import 'package:zineplayer/Home/Screen%20functions/play_screen_functions.dart';
import 'package:zineplayer/Home/Screen%20widgets/play_screen_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zineplayer/functions/datamodels.dart';

class PlayScreen extends StatefulWidget {
  final String videoFile;
  final String videotitle;
  int duration;

  PlayScreen(
      {super.key,
      required this.videoFile,
      required this.videotitle,
      required this.duration});
  @override
  PlayScreenState createState() => PlayScreenState();
}

class PlayScreenState extends State<PlayScreen> {
  late VideoPlayerController _controller;
  String currentDuration = '0';
  Duration resumeDuration = const Duration();
  int _index = 0;
  Color color = const Color.fromARGB(255, 158, 155, 155);
  late String barColor;
  @override
  void initState() {
    barcolorFunction();
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoFile));
    _controller.addListener(() {
      setState(() {
        currentDuration = _controller.value.position.toString();
      });
    });
    _controller.setLooping(true);
    _controller.initialize().then((_) => setState(() {}));
    _controller.play();
    setLandscape(context, widget, _controller, widget.videoFile);
    screenVisibility();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isPortrait = orientation == Orientation.portrait;
          return GestureDetector(
            onTap: () => screenVisibility(),
            onDoubleTap: () {
              isLocked ? null : playFunction();
            },
            onPanUpdate: (details) {
              swipeFunction(details);
            },
            child: Stack(children: <Widget>[
              videoContent(fit: fit, controller: _controller, index: _index),
              durationSwipe(),
              Center(child: playPauseBool ? playpause() : null),
              leftseekContainer(orientation: orientation),
              rightseekContainer(orientation: orientation),
              topBar(isPortrait: isPortrait),
              bottomBar(orientation),
              indicatorNduration(orientation: orientation),
              lockButton(orientation),
            ]),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    setAllOrientations();
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    DeviceOrientation.landscapeLeft;
    int totalduration = _controller.value.duration.inSeconds;
    widget.duration = _controller.value.position.inSeconds;
    addToRecentList(
        title: widget.videotitle,
        context: context,
        videoPath: widget.videoFile,
        totalduration: totalduration,
        durationinSec: widget.duration);
    Wakelock.disable();
  }

  Widget rightseekContainer({required orientation}) => GestureDetector(
        onLongPressMoveUpdate: (details) {},
        child: Container(
          margin: orientation == Orientation.landscape
              ? const EdgeInsets.only(top: 60.0, left: 550.0)
              : const EdgeInsets.only(top: 100.0, left: 260.0),
          width: orientation == Orientation.landscape ? 320.0 : 150.0,
          height: orientation == Orientation.landscape ? 270.0 : 650.0,
          color: transparent,
          child: InkWell(
            onTap: () => screenVisibility(),
            onDoubleTap: () {
              isLocked ? null : forwardSec(10);
              setState(() {
                isLocked ? null : leftText = plusten;
                isLocked ? null : isrRightIconVisible = true;
              });
              Future.delayed(
                const Duration(milliseconds: 500),
                () => setState(() {
                  leftText = '';
                  isrRightIconVisible = false;
                }),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                        child: isrRightIconVisible
                            ? screenIcon(Icons.fast_forward)
                            : null),
                    seekText(leftText)
                  ],
                ),
                brightnessSlider(),
              ],
            ),
          ),
        ),
      );
  Widget screenIcon(icon) => Icon(
        icon,
        size: 30.0,
        color: white,
      );
  Widget durationSwipe() => Center(
          child: Text(
        textDur,
        style: TextStyle(fontSize: 30.0, color: white),
      ));
  Widget leftseekContainer({required orientation}) => GestureDetector(
        child: Container(
          margin: orientation == Orientation.landscape
              ? const EdgeInsets.only(
                  top: 60.0,
                )
              : const EdgeInsets.only(top: 100.0),
          width: orientation == Orientation.landscape ? 320.0 : 150.0,
          height: orientation == Orientation.landscape ? 270.0 : 650.0,
          color: transparent,
          child: InkWell(
            onTap: () => screenVisibility(),
            onDoubleTap: () {
              isLocked ? null : rewindSec(10);
              setState(() {
                isLocked ? null : rightText = minusten;
                isLocked ? null : isLeftIconVisible = true;
              });

              Future.delayed(
                const Duration(milliseconds: 500),
                () => setState(() {
                  rightText = '';
                  isLeftIconVisible = false;
                }),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Center(child: volumeSlider()),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                        child: isLeftIconVisible
                            ? screenIcon(Icons.fast_rewind)
                            : null),
                    seekText(rightText)
                  ],
                ),
              ],
            ),
          ),
        ),
      );
  Widget seekText(text) => Text(
        text,
        style: TextStyle(
            color: white, fontWeight: FontWeight.bold, fontSize: 20.0),
      );
  playFunction() {
    _controller.value.isPlaying
        ? setState(() {
            _controller.pause();
            playPauseBool = true;
            Future.delayed(
                const Duration(milliseconds: 500), () => playPauseBool = false);
          })
        : setState(() {
            _controller.play();
            playPauseBool = true;
            Future.delayed(
                const Duration(milliseconds: 500), () => playPauseBool = false);
          });
  }

  Widget bottomBar(orientation) => Visibility(
        visible: isShow,
        child: Container(
          margin: orientation == Orientation.landscape
              ? const EdgeInsets.only(top: 350.0, bottom: 0.0)
              : const EdgeInsets.only(top: 800.0, bottom: 0.0),
          width: double.infinity,
          height: 100,
          color: color,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                width: 110.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () {
                        rewindSec(10);
                      },
                      icon: Icon(
                        Icons.fast_rewind,
                        color: white,
                        size: 40.0,
                      )),
                  IconButton(
                      onPressed: () {
                        playFunction();
                      },
                      icon: playpause()),
                  IconButton(
                    icon: const Icon(
                      Icons.fast_forward,
                      size: 40.0,
                    ),
                    onPressed: () {
                      forwardSec(10);
                    },
                    color: white,
                  )
                ],
              ),
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          _index = (_index + 1) % fit.length;
                        });
                      },
                      color: white,
                      icon: const Icon(Icons.fit_screen)),
                  IconButton(
                      onPressed: () {
                        // Navigator.of(context).push(
                        //       PipScreen(videoPath: widget.videoFile),
                        // ));
                      },
                      color: white,
                      icon: const Icon(Icons.picture_in_picture_alt)),
                ],
              )
            ],
          ),
        ),
      );

  screenVisibility() async {
    setState(() {
      isLocked ? isShow = false : isShow = !isShow;

      isShow ? isLockButton = true : isLockButton = !isLockButton;
    });
    if (isShow == true) {
      await Future.delayed(const Duration(seconds: 5));
      isShow = false;
      isLockButton = false;
    }
  }

  Widget playpause() => Icon(
        _controller.value.isPlaying ? Icons.play_arrow : Icons.pause,
        color: white,
        size: 40.0,
      );

  Widget lockButton(
    Orientation orientation,
  ) =>
      Container(
        color: isLocked ? color : transparent,
        margin: orientation == Orientation.landscape
            ? const EdgeInsets.only(top: 370.0, left: 3.0)
            : const EdgeInsets.only(top: 820.0),
        child: Visibility(
          visible: isLockButton,
          child: IconButton(
            onPressed: () {
              setState(() {
                isLocked = !isLocked;
                isLocked ? isShow = false : isShow = true;
              });
            },
            icon:
                isLocked ? const Icon(Icons.lock) : const Icon(Icons.lock_open),
            color: white,
          ),
        ),
      );
  double val = 0.5;
  Widget brightnessSlider() => Visibility(
        visible: isShow,
        child: SliderTheme(
            data: SliderThemeData(
              thumbColor: white,
              trackHeight: 1.0,
            ),
            child: Column(
              children: [
                Column(
                  children: [
                    SizedBox(
                      width: 100.0,
                      child: SfSlider.vertical(
                        inactiveColor: white,
                        activeColor: bluecolor,
                        min: 0.0,
                        max: 1.0,
                        value: val,
                        onChanged: (value) {
                          setState(() {
                            val = value;
                            FlutterScreenWake.setBrightness(val);
                          });
                        },
                      ),
                    ),
                  ],
                ),
                val == 0.0
                    ? Icon(Icons.brightness_low, color: white)
                    : Icon(Icons.brightness_high, color: white),
              ],
            )),
      );

  double vol = 0.5;
  Widget volumeSlider() => Visibility(
        visible: isShow,
        child: SliderTheme(
            data: SliderThemeData(
              thumbColor: white,
              trackHeight: 1.0,
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 150.0,
                      child: SfSlider.vertical(
                        inactiveColor: white,
                        activeColor: bluecolor,
                        min: 0.0,
                        max: 1.0,
                        value: vol,
                        onChanged: (value) {
                          setState(() {
                            vol = value;
                            _controller.setVolume(vol);
                          });
                        },
                      ),
                    ),
                  ],
                ),
                vol != 0.0
                    ? Icon(Icons.volume_up, color: white)
                    : Icon(Icons.volume_off, color: white)
              ],
            )),
      );

  swipeFunction(details) {
    if (details.delta.dy > 0 || details.delta.dy < 0) {
      return;
    } else if (details.delta.dx > 0) {
      isLocked ? null : forwardSec(5);
      setState(() {
        isLocked ? null : textDur = "[${currentDuration.split(".").first}]";
        Future.delayed(
          const Duration(milliseconds: 500),
          () => setState(() {
            textDur = '';
          }),
        );
      });
    } else if (details.delta.dx < 0) {
      isLocked ? null : rewindSec(5);
      setState(() {
        isLocked ? null : textDur = "[${currentDuration.split(".").first}]";
        Future.delayed(
          const Duration(milliseconds: 500),
          () => setState(() {
            textDur = '';
          }),
        );
      });
    }
  }

  Widget topBar({
    required isPortrait,
  }) =>
      Visibility(
        visible: isShow,
        child: Container(
          margin: const EdgeInsets.only(top: 0.0),
          width: double.infinity,
          height: 60,
          color: color,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Wakelock.disable();
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: white,
                  )),
              Text(
                widget.videotitle,
                style: TextStyle(color: white),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.screen_rotation),
                    onPressed: () {
                      rotate(isPortrait);
                    },
                    color: white,
                  ),
                  playSpeed(controller: _controller, setState: setState),
                ],
              )
            ],
          ),
        ),
      );
  Widget indicatorNduration({required orientation}) => Container(
        margin: orientation == Orientation.landscape
            ? const EdgeInsets.only(top: 0.0)
            : const EdgeInsets.only(top: 450.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            duration(currentDuration.split('.').first,
                isShow: isShow,
                text: currentDuration.toString().split('.').first),
            Container(
                width: orientation == Orientation.landscape ? 750.0 : 270.0,
                margin: const EdgeInsets.only(top: 350.0),
                child: indicator(controller: _controller, isShow: isShow)),
            duration(_controller.value.duration.toString().split('.').first,
                isShow: isShow,
                text: _controller.value.duration.toString().split('.').first)
          ],
        ),
      );
  forwardSec(sec) {
    _controller.seekTo(_controller.value.position + Duration(seconds: sec));
  }

  rewindSec(sec) {
    _controller.seekTo(_controller.value.position - Duration(seconds: sec));
  }

  barcolorFunction() async {
    final colorhive = await Hive.openBox<FrameColor>('colorBox');
    FrameColor? bar = colorhive.getAt(0);

    barColor = bar!.color.toString();
    log("$barColor");
    int colorInt = int.parse(
        barColor.substring(barColor.indexOf("(") + 1, barColor.indexOf(")")));
    setState(() {
      color = Color(colorInt);
    });
  }
}

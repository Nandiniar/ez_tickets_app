import 'package:auto_route/auto_route.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Helpers
import '../../helper/utils/constants.dart';

//Providers
import '../../providers/movies_provider.dart';

class TrailerScreen extends StatefulWidget {
  const TrailerScreen();

  @override
  _TrailerScreenState createState() => _TrailerScreenState();
}

class _TrailerScreenState extends State<TrailerScreen> {
  late final BetterPlayerController _betterPlayerController;

  final _controlsConfiguration = const BetterPlayerControlsConfiguration(
    overflowModalTextColor: Constants.textGreyColor,
    overflowMenuIconsColor: Constants.textGreyColor,
    overflowModalColor: Constants.scaffoldGreyColor,
    progressBarPlayedColor: Constants.primaryColor,
    progressBarHandleColor: Constants.primaryColor,
    backgroundColor: Colors.black38,
    controlBarColor: Colors.black54,
    enablePip: false,
    enableSubtitles: false,
  );

  @override
  void initState() {
    super.initState();
    final betterPlayerConfiguration = BetterPlayerConfiguration(
      aspectRatio: 4 / 3,
      fullScreenAspectRatio: 16 / 9,
      looping: false,
      autoPlay: true,
      fit: BoxFit.cover,
      allowedScreenSleep: false,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
      systemOverlaysAfterFullScreen: [SystemUiOverlay.top],
      fullScreenByDefault: true,
      autoDetectFullscreenDeviceOrientation: true,
      controlsConfiguration: _controlsConfiguration,
      errorBuilder: _buildErrorWidget,
    );
    final trailerUrl = context.read(selectedMovieProvider).state.trailerUrl;
    final betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      trailerUrl,
    );
    _betterPlayerController = BetterPlayerController(
      betterPlayerConfiguration,
      betterPlayerDataSource: betterPlayerDataSource,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            //Back and title
            Row(
              children: [
                const SizedBox(width: 15),
                GestureDetector(
                  child: const Icon(Icons.arrow_back_sharp, size: 30),
                  onTap: () {
                    context.router.pop();
                  },
                ),
                const SizedBox(width: 70),

                //Movie Title
                Consumer(
                  builder: (_, watch, __) {
                    final title = watch(selectedMovieProvider).state.title;
                    return Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .headline3!
                          .copyWith(fontSize: 28),
                    );
                  },
                ),
              ],
            ),

            Expanded(child: BetterPlayer(controller: _betterPlayerController)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(context, errorMessage) {
    debugPrint(errorMessage);
    return const Center(
      child: Text(
        "Playback Error",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
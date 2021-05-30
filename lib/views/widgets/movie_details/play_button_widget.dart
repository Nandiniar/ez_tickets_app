import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:auto_route/auto_route.dart';
import "package:hooks_riverpod/hooks_riverpod.dart";

//Providers
import 'movie_details_sheet.dart' show btnScaleRatioProvider;

//Routes
import '../../../routes/app_router.gr.dart';

class PlayButtonWidget extends HookWidget {
  const PlayButtonWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final btnScaleRatio = useProvider(btnScaleRatioProvider).state;
    return ElevatedButton(
      onPressed: () {
        context.router.push(const TrailerScreenRoute());
      },
      style: ElevatedButton.styleFrom(
        elevation: 5,
        minimumSize: Size.fromRadius(btnScaleRatio * 28.5),
        primary: Colors.white,
        padding: const EdgeInsets.all(0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(50.0)),
        ),
      ),
      child: Icon(
        Icons.play_arrow_sharp,
        size: btnScaleRatio * 35,
        color: Colors.black,
      ),
    );
  }
}
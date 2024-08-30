import 'package:flutter/material.dart';
import 'package:librairian/constants/keys.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

List<TargetFocus> createTargets(BuildContext context) => [
      TargetFocus(
        keyTarget: storageNavKey,
        alignSkip: Alignment.bottomCenter,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.right,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "First, create a storage zone",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      TargetFocus(
        keyTarget: addNavKey,
        alignSkip: Alignment.bottomCenter,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.right,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Then, you can add new items in your storage zones",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      TargetFocus(
        keyTarget: searchNavKey,
        alignSkip: Alignment.bottomCenter,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.right,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "You can now search for them!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      TargetFocus(
        keyTarget: inventoryNavKey,
        alignSkip: Alignment.bottomCenter,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.right,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Here you can list and manage all your items!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ];

TutorialCoachMark createTutorial(BuildContext context) {
  return TutorialCoachMark(
    targets: createTargets(context),
    colorShadow: Theme.of(context).colorScheme.secondary,
    textSkip: "SKIP",
    paddingFocus: 10,
    opacityShadow: 0.8,
    onClickTarget: (target) {
      print(target);
    },
    onClickOverlay: (target) {},
    onSkip: () {
      return true;
    },
  );
}

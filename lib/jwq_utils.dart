library jwq_utils;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Originally from: https://stackoverflow.com/a/71427895
// - Adjustable scroll speed
// - Saves scroll position between clients
class AdjustableScrollController extends ScrollController {
  double? savedPos;

  AdjustableScrollController([int extraScrollSpeed = 40]) {
    super.addListener(() {
      ScrollDirection scrollDirection = super.position.userScrollDirection;
      if (scrollDirection != ScrollDirection.idle) {
        double scrollEnd = super.offset +
            (scrollDirection == ScrollDirection.reverse
                ? extraScrollSpeed
                : -extraScrollSpeed);
        scrollEnd = min(super.position.maxScrollExtent,
            max(super.position.minScrollExtent, scrollEnd));
        jumpTo(scrollEnd);
      }
    });
  }

  @override
  void attach(ScrollPosition position) {
    if (savedPos != null) {
      position.correctPixels(savedPos!);
    }
    super.attach(position);
  }

  @override
  void detach(ScrollPosition position) {
    savedPos = offset;
    super.detach(position);
  }
}

// Based on: https://codewithandrea.com/articles/flutter-responsive-layouts-split-view-drawer-navigation/
class SplitView extends StatelessWidget {
  final Widget? title;
  final Widget body, drawer;
  final double menuWidth;
  final Widget? floatingActionButton;

  const SplitView({
    Key? key,
    required this.body,
    required this.drawer,
    this.title,
    this.menuWidth = 300,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < menuWidth * 3) {
      return Scaffold(
        appBar: AppBar(title: title),
        drawer: drawer,
        body: body,
        floatingActionButton: floatingActionButton,
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: title),
        body: Row(children: [
          SizedBox(width: menuWidth, child: drawer),
          Container(width: 0.5, color: Colors.black),
          Expanded(child: body),
        ]),
        floatingActionButton: floatingActionButton,
      );
    }
  }
}

ButtonStyle elevatedButtonStyle(BuildContext context, {Color? color}) {
  return TextButton.styleFrom(
    primary: color ?? Theme.of(context).colorScheme.primary,
    backgroundColor: Theme.of(context).colorScheme.surface,
    elevation: 3,
    padding: const EdgeInsets.all(8),
  );
}

Future<bool> confirm(BuildContext context,
    [String title = 'Are you sure?']) async {
  bool response = false;
  await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          actions: [
            TextButton(
              style: elevatedButtonStyle(context, color: Colors.red),
              child: const Text('Yes'),
              onPressed: () {
                response = true;
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: elevatedButtonStyle(context),
              child: const Text('No'),
              onPressed: () {
                response = false;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
  return response;
}

Future<String?> inputText(BuildContext context,
    {String? initial, String? title, String? label}) async {
  String? txt = initial;
  await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: title == null ? null : Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: label),
                initialValue: initial,
                onChanged: (str) {
                  txt = str;
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                child: const Text('Ok'),
                style: elevatedButtonStyle(context),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        );
      });
  return txt;
}

import 'package:flutter/material.dart';

IconData storeBackIcon(BuildContext context) =>
    Directionality.of(context) == TextDirection.rtl
        ? Icons.arrow_forward_ios_rounded
        : Icons.arrow_back_ios_new_rounded;

IconData storeForwardIcon(BuildContext context) =>
    Directionality.of(context) == TextDirection.rtl
        ? Icons.arrow_back_ios_new_rounded
        : Icons.arrow_forward_ios_rounded;

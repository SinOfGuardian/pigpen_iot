import 'package:flutter/material.dart';
import 'package:pigpen_iot/custom/app_cachednetworkimage.dart';
import 'package:pigpen_iot/custom/app_text.dart';


class Header extends StatelessWidget {
  final String title;
  final String? description;
  final String? graphicUrl;
  const Header({
    super.key,
    required this.title,
    this.description,
    this.graphicUrl,
  });

  const Header.titleOnly({
    super.key,
    required this.title,
    this.description,
    this.graphicUrl,
  })  : assert(description == null,
            'Cannot add description, use titleWithDescription instead'),
        assert(graphicUrl == null,
            'Cannot add deviceGraphic, use titleWithDeviceGraphic instead');

  const Header.titleWithDescription({
    required this.title,
    required this.description,
    this.graphicUrl,
    super.key,
  }) : assert(graphicUrl == null,
            'Cannot add deviceGraphic, use titleWithDeviceGraphic instead');

  const Header.titleWithDeviceGraphic({
    super.key,
    required this.title,
    required this.description,
    required this.graphicUrl,
  }) : assert(description != null && graphicUrl != null,
            'Header of Plant, description and deviceGraphic cannot be null');

  Widget _trailingWidget(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      height: 40,
      width: 40,
      child: OverflowBox(
        alignment: Alignment.topCenter,
        maxHeight: 50,
        child: AppCachedNetworkImage(graphicUrl),
      ),
    );
  }

  Widget _description() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: AppText.description16(description ?? ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FormTitle(title),
            if (graphicUrl != null) _trailingWidget(context),
          ],
        ),
        if (description != null) _description(),
      ],
    );
  }
}

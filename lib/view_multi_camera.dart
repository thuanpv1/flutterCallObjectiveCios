import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MultiCameraView extends StatefulWidget {
  const MultiCameraView({Key? key}) : super(key: key);

  @override
  State<MultiCameraView> createState() => _MultiCameraViewState();
}

class _MultiCameraViewState extends State<MultiCameraView> {
  String viewType = '<platform-view-type>';
  final Map<String, dynamic> creationParams = <String, dynamic>{
    'serial': '55685723|54110161',
    'viewMode': 'multi',
    'isShowToolBtns': 'false',
    'deviceIndex': 0,
    'isMultiView': 'true'
  };

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width *9/16 + 115,
              color: Colors.yellow,
              child: UiKitView(
              viewType: viewType,
              layoutDirection: TextDirection.ltr,
              creationParams: creationParams,
              creationParamsCodec: const StandardMessageCodec(),
            ),
            ),
          );
  }
}

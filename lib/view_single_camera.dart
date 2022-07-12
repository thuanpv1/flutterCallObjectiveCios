import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SingleCameraView extends StatefulWidget {
  const SingleCameraView({Key? key}) : super(key: key);

  @override
  State<SingleCameraView> createState() => _SingleCameraViewState();
}

class _SingleCameraViewState extends State<SingleCameraView> {
  String viewType = '<platform-view-type>';
  final Map<String, dynamic> creationParams = <String, dynamic>{
    'serial': '55685723|54110161',
    'viewMode': 'single'
  };
  
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
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

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tmv_lite/utils/hexcolor.dart';

class CustomListLoadingWidget extends StatefulWidget {
  final int length;
  const CustomListLoadingWidget({Key? key, this.length = 10}) : super(key: key);

  @override
  State<CustomListLoadingWidget> createState() => _CustomListLoadingWidgetState();
}

class _CustomListLoadingWidgetState extends State<CustomListLoadingWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: Shimmer.fromColors(
                baseColor: HexColor("#F9FAFF"),
                highlightColor: Colors.blue[50]!,
                enabled: true,
                child: ListView.builder(
                  itemBuilder: (_, __) => Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: ListTile(
                      dense:true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16,vertical: 6),
                      title: Container(
                        width: double.infinity,
                        height: 8.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Container(
                        width: double.infinity,
                        height: 8.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  itemCount: widget.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
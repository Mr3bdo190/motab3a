import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class OfflineBanner extends StatefulWidget {
  final Widget child;
  const OfflineBanner({super.key, required this.child});
  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      setState(() {
        _isOffline = results.contains(ConnectivityResult.none);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isOffline)
          Material(
            color: Colors.red,
            child: SafeArea(
              bottom: false,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                child: const Text('أنت غير متصل بالإنترنت - التغييرات يتم حفظها محلياً', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}

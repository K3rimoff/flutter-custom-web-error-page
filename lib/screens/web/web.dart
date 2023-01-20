import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../components/back_pressed.dart';
import '../../theme/colors.dart';
import '../error/error.dart';

class WebScreen extends StatefulWidget {
  const WebScreen({super.key});

  @override
  State<WebScreen> createState() => _WebScreenState();
}

class _WebScreenState extends State<WebScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  InAppWebViewController? _webViewController;
  PullToRefreshController? _refreshController;

  bool _isLoading = false, _isVisible = false, _isOffline = false;

  // 0 - Everything is ok, 1 - http or other error fixed
  int _errorCode = 0;
  final BackPressed _backPressed = BackPressed();

  Future<void> checkError() async {
    //Hide CircularProgressIndicator
    _isLoading = false;

    //Check Network Status
    ConnectivityResult result = await Connectivity().checkConnectivity();

    //if Online: hide offline page and show web page
    if (result != ConnectivityResult.none) {
      if (_isOffline == true) {
        _isVisible = false; //Hide Offline Page
        _isOffline = false; //set Page type to error
      }
    }

    //If Offline: hide web page show offline page
    else {
      _errorCode = 0;
      _isOffline = true; //Set Page type to offline
      _isVisible = true; //Show offline page
    }

    // If error is fixed: hide error page and show web page
    if (_errorCode == 1) _isVisible = false;
    setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animationController.repeat();
    _refreshController = PullToRefreshController(
      onRefresh: () => _webViewController!.reload(),
      options: PullToRefreshOptions(
          color: Colors.white, backgroundColor: Colors.black87),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          body: SafeArea(
            child: Stack(
              alignment: Alignment.center,
              children: [
                InAppWebView(
                  onWebViewCreated: (controller) =>
                      _webViewController = controller,
                  initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                    supportZoom: false,
                  )),
                  initialUrlRequest: URLRequest(
                      url: Uri.parse(
                          "https://google.com")), // For http error: change to wrong url : https://google.com/404/
                  pullToRefreshController: _refreshController,
                  onLoadStart: (controller, url) {
                    setState(() {
                      _isLoading = true; //Show CircularProgressIndicator
                    });
                  },
                  onLoadStop: (controller, url) {
                    _refreshController!.endRefreshing();
                    checkError(); //Check Error type: offline or other error
                  },
                  onLoadError: (controller, url, code, message) {
                    // Show
                    _errorCode = code;
                    _isVisible = true;
                  },
                  onLoadHttpError: (controller, url, statusCode, description) {
                    _errorCode = statusCode;
                    _isVisible = true;
                  },
                ),
                //Error Page
                Visibility(
                  visible: _isVisible,
                  child: ErrorScreen(
                      isOffline: _isOffline,
                      onPressed: () {
                        _webViewController!.reload();
                        if (_errorCode != 0) {
                          _errorCode = 1;
                        }
                      }),
                ),
                //CircularProgressIndicator
                Visibility(
                  visible: _isLoading,
                  child: CircularProgressIndicator.adaptive(
                    valueColor: _animationController.drive(
                      ColorTween(
                          begin: circularProgressBegin,
                          end: circularProgressEnd),
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _errorCode = 1;//My Error fixed code
                  _webViewController!.loadUrl(
                    urlRequest: URLRequest(
                      url: Uri.parse("https://google.com/"), //Correct url
                    ),
                  );
                },
                label: const Text("Load Correct URL"),
                icon: const Icon(Icons.check),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _webViewController!.loadUrl(
                    urlRequest: URLRequest(
                      url: Uri.parse("https://google.com/404"), //Wrong url
                    ),
                  );
                },
                label: const Text("Load Wrong URL"),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        onWillPop: () async {
          //If website can go back page
          if (await _webViewController!.canGoBack()) {
            await _webViewController!.goBack();
            return false;
          } else {
            //Double pressed to exit app
            return _backPressed.exit(context);
          }
        });
  }
}

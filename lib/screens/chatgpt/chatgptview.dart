// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member, deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart' as url;

class ChatGPTViewer extends StatefulWidget {
  const ChatGPTViewer({super.key});

  @override
  State<ChatGPTViewer> createState() => _ChatGPTViewerState();
}

class _ChatGPTViewerState extends State<ChatGPTViewer> {
  ValueNotifier progressIndicator = ValueNotifier(0);

  //webview controller
  late WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          //sets progress when loading a url/page
          progressIndicator.value = progress / 100;
          progressIndicator.notifyListeners();
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) async {
          //resets progress to zero
          progressIndicator.value = 0;
          progressIndicator.notifyListeners();
        },
        onWebResourceError: (WebResourceError error) {
          debugPrint('WebView Error: $error');
        },
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('https://www.youtube.com/')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    )
    ..loadRequest(Uri.parse('https://chat.openai.com'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leadingWidth: 100,
        backgroundColor: Colors.white,
        //leading icon buttons: [Back and Forward]
        leading: toolbarLeadingActionButtons(),
        centerTitle: true,
        title: Text(
          "ChatGPT+",
          style: GoogleFonts.poppins().copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        //trailing icons: [reload and instagram]
        actions: toolbarActionWidgets(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //loading progress bar
          progressIndicatorBar(),
          //body, webview widget
          Expanded(
            child: WebViewWidget(
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }

  Widget progressIndicatorBar() {
    return ValueListenableBuilder(
      valueListenable: progressIndicator,
      builder: (context, value, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: MediaQuery.of(context).size.width * value,
          height: 1.85,
          color: Colors.black,
        );
      },
    );
  }

  Widget toolbarLeadingActionButtons() {
    return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 10),
            Bounceable(
              onTap: () async {
                if (await controller.canGoBack()) {
                  controller.goBack();
                }
              },
              child: const Icon(
                CupertinoIcons.back,
                color: Colors.black,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Bounceable(
              onTap: () async {
                if (await controller.canGoForward()) {
                  controller.goForward();
                }
              },
              child: const Icon(
                CupertinoIcons.forward,
                color: Colors.black,
                size: 22,
              ),
            ),
          ],
        );
  }

  List<Widget> toolbarActionWidgets() {
    return <Widget>[
      Bounceable(
        onTap: () {
          controller.reload();
        },
        child: SvgPicture.asset(
          "assets/reload.svg",
          color: Colors.black,
          height: 20,
        ),
      ),
      const SizedBox(width: 15),
      Bounceable(
        onTap: () {
          url.launchUrl(
            Uri.parse("https://instagram.com/jonace.mpelule"),
          );
        },
        child: SvgPicture.asset(
          "assets/instagram.svg",
          color: Colors.black,
          height: 20,
        ),
      ),
      const SizedBox(width: 15),
    ];
  }
}

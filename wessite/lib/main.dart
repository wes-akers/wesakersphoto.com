import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:common/flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const WessiteApp());
}

const kGalleryPrefix = 'images/';

class WessiteApp extends StatefulWidget {
  const WessiteApp({super.key});

  @override
  State<WessiteApp> createState() => _WessiteAppState();
}

class WessitePage extends StatelessWidget {
  final Widget child;
  final String email;
  final String instagram;

  const WessitePage({
    Key? key,
    required this.child,
    required this.email,
    required this.instagram,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          child,
          Center(
            child: Column(
              children: [
                const SizedBox(height: 32),
                IconButton(
                  onPressed: () =>
                      launchUrl(Uri.parse('http://instagram.com/$instagram')),
                  icon: const Icon(FontAwesomeIcons.instagram),
                ),
                IconButton(
                  onPressed: () => launchUrl(Uri.parse('mailto:$email')),
                  icon: const Icon(Icons.email_outlined),
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
        ],
      );
}

class _WessiteAppState extends State<WessiteApp> {
  final scroll = ScrollController();
  bool loaded = false;

  final galleryImages = <String, List<String>>{};

  final carousel = CarouselController();

  String email = '';
  String instagram = '';
  String about = '';

  Iterable<String> get galleryNames =>
      galleryImages.keys.where((name) => name != '_home');

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return const Center(child: CircularProgressIndicator());
    }
    return GoRouterApp(
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: NoTransitionsBuilder(),
            TargetPlatform.iOS: NoTransitionsBuilder(),
            TargetPlatform.linux: NoTransitionsBuilder(),
            TargetPlatform.macOS: NoTransitionsBuilder(),
            TargetPlatform.windows: NoTransitionsBuilder(),
          },
        ),
      ),
      appName: 'Wes Akers Photography',
      shellBuilder: (context, state, child) =>
          LayoutBuilder(builder: (context, constraints) {
        return Scaffold(
          body: SingleChildScrollView(
            controller: scroll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => context.goNamed('home'),
                        child: Text(
                          'Wes Akers Photography',
                          style: context.textTheme.titleLarge,
                        ),
                      ),
                      const Spacer(),
                      if (constraints.maxWidth >= 640) ...[
                        MenuAnchor(
                          builder: (context, controller, child) => TextButton(
                            onPressed: controller.open,
                            child: Text(
                              'Work',
                              style: context.textTheme.titleMedium?.copyWith(
                                decoration: galleryNames.any((element) =>
                                        element ==
                                        context.location
                                            .toString()
                                            .replaceAll('/', ''))
                                    ? TextDecoration.underline
                                    : null,
                              ),
                            ),
                          ),
                          menuChildren: _galleryMenuChildren(context),
                        ),
                        TextButton(
                          onPressed: () => context.goNamed('about'),
                          child: Text(
                            'About',
                            style: context.textTheme.titleMedium?.copyWith(
                              decoration:
                                  context.location.toString().endsWith('about')
                                      ? TextDecoration.underline
                                      : null,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                child,
              ],
            ),
          ),
          floatingActionButton: constraints.maxWidth < 640
              ? Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: MenuAnchor(
                          builder: (context, controller, child) => IconButton(
                            onPressed: controller.open,
                            icon: const Icon(Icons.menu),
                          ),
                          menuChildren: [
                            SubmenuButton(
                              style: SubmenuButton.styleFrom(
                                  iconColor: Colors.transparent),
                              menuChildren: _galleryMenuChildren(context),
                              leadingIcon: Icon(
                                Icons.keyboard_arrow_left,
                                color: context.colorScheme.primary,
                              ),
                              child: Text('Work',
                                  style: TextStyle(
                                    decoration: galleryNames.any((element) =>
                                            element ==
                                            context.location
                                                .toString()
                                                .replaceAll('/', ''))
                                        ? TextDecoration.underline
                                        : null,
                                  )),
                            ),
                            MenuItemButton(
                              leadingIcon: const Icon(
                                Icons.keyboard_arrow_left,
                                color: Colors.transparent,
                              ),
                              child: Text(
                                'About',
                                style: TextStyle(
                                  decoration: context.location
                                          .toString()
                                          .endsWith('about')
                                      ? TextDecoration.underline
                                      : null,
                                ),
                              ),
                              onPressed: () => context.goNamed('about'),
                            )
                          ],
                          child: const Icon(Icons.menu),
                        ),
                      ),
                    ),
                  ),
                )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
        );
      }),
      routes: [
        GoRouterConfig(
          name: 'home',
          path: '/',
          builder: (context, state) => _galleryBuilder('_home'),
        ),
        GoRouterConfig(
          name: 'about',
          path: '/about',
          builder: (context, state) {
            return Row(
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Image.network('about.png'),
                )),
                Container(
                  padding: const EdgeInsets.all(32),
                  width: 480,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(about),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        label: Text('@$instagram'),
                        onPressed: () => launchUrl(
                            Uri.parse('http://instagram.com/$instagram')),
                        icon: const Icon(FontAwesomeIcons.instagram),
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        label: Text(email),
                        onPressed: () => launchUrl(Uri.parse('mailto:$email')),
                        icon: const Icon(Icons.email_outlined),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        for (final gallery in galleryNames)
          GoRouterConfig(
            name: gallery,
            path: '/$gallery',
            builder: (context, state) => _galleryBuilder(gallery),
          ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    final futures = <Future>[
      http.get(Uri.parse('about.txt')).then((value) => about = value.body),
      http
          .get(Uri.parse('email.txt'))
          .then((value) => email = value.body.trim()),
      http
          .get(Uri.parse('instagram.txt'))
          .then((value) => instagram = value.body.trim()),
    ];
    futures.add(
        rootBundle.loadString('assets/images-list.txt').then((value) async {
      for (final filename in value.trim().split('\n')) {
        final galleryName = filename.split('/')[1];
        galleryImages[galleryName] ??= [];
        galleryImages[galleryName]!.add(filename);
      }
    }));
    Future.wait(futures).then((value) => setState(() => loaded = true));
  }

  Widget _galleryBuilder(String gallery) {
    final items = galleryImages[gallery]!;
    return WessitePage(
      email: email,
      instagram: instagram,
      child: Row(
        children: [
          const SizedBox(width: 32),
          IconButton(
              onPressed: carousel.previousPage,
              icon: const Icon(Icons.keyboard_arrow_left)),
          Expanded(
            child: CarouselSlider.builder(
              carouselController: carousel,
              options: CarouselOptions(
                  // aspectRatio: 1,
                  viewportFraction: 1.0,
                  scrollPhysics: const NeverScrollableScrollPhysics()),
              itemCount: items.length,
              itemBuilder:
                  (BuildContext context, int itemIndex, int pageViewIndex) =>
                      Image.network(items[itemIndex]),
            ),
          ),
          IconButton(
              onPressed: carousel.nextPage,
              icon: const Icon(Icons.keyboard_arrow_right)),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  List<MenuItemButton> _galleryMenuChildren(BuildContext context) => [
        for (final gallery in galleryNames)
          MenuItemButton(
            child: Text(
              gallery.replaceAll('_', ' ').toTitleCase(),
            ),
            onPressed: () => context.goNamed(gallery),
          ),
      ];
}

extension TitleCase on String {
  String toTitleCase() {
    if (length <= 1) return toUpperCase();
    var words = split(' ');
    var capitalized = words.map((word) {
      var first = word.substring(0, 1).toUpperCase();
      var rest = word.substring(1);
      return '$first$rest';
    });
    return capitalized.join(' ');
  }
}

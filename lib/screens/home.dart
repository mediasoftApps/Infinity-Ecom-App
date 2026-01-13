import 'package:infinity_ecom_app/app_config.dart';
import 'package:infinity_ecom_app/custom/flash%20deals%20banner/flash_deal_banner.dart';
import 'package:infinity_ecom_app/helpers/shared_value_helper.dart';
import 'package:infinity_ecom_app/helpers/shimmer_helper.dart';
import 'package:infinity_ecom_app/l10n/app_localizations.dart';
import 'package:infinity_ecom_app/my_theme.dart';
import 'package:infinity_ecom_app/presenter/home_presenter.dart';
import 'package:infinity_ecom_app/screens/filter.dart';
import 'package:infinity_ecom_app/screens/flash_deal/flash_deal_list.dart';
import 'package:infinity_ecom_app/screens/product/todays_deal_products.dart';
import 'package:infinity_ecom_app/screens/top_sellers.dart';
import 'package:infinity_ecom_app/single_banner/sincle_banner_page.dart';
import 'package:flutter/material.dart';
import '../custom/feature_categories_widget.dart';
import '../custom/featured_product_horizontal_list_widget.dart';
import '../custom/home_all_products_2.dart';
import '../custom/home_banner_one.dart';
import '../custom/home_carousel_slider.dart';
import '../custom/home_search_box.dart';
import '../custom/pirated_widget.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
    this.title,
    this.show_back_button = false,
    this.go_back = true,
  });

  final String? title;
  final bool show_back_button;
  final bool go_back;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final HomePresenter homeData = HomePresenter();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
      precacheImage(const AssetImage("assets/todays_deal.png"), context);
      precacheImage(const AssetImage("assets/flash_deal.png"), context);
      precacheImage(const AssetImage("assets/brands.png"), context);
      precacheImage(const AssetImage("assets/top_sellers.png"), context);
    });
    homeData.mainScrollListener();
    homeData.initPiratedAnimation(this);
  }

  Future<void> _fetchData() {
    return homeData.onRefresh();
  }

  @override
  void dispose() {
    homeData.pirated_logo_controller.dispose();
    homeData.mainScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => widget.go_back,
      child: Directionality(
        textDirection: app_language_rtl.$!
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: SafeArea(
          child: Scaffold(
            appBar: const _HomeAppBar(),
            backgroundColor: Colors.white,

            body: Stack(
              children: [
                RefreshIndicator(
                  color: MyTheme.accent_color,
                  backgroundColor: Colors.white,
                  onRefresh: _fetchData,
                  displacement: 0,
                  child: CustomScrollView(
                    controller: homeData.mainScrollController,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: <Widget>[
                      _buildHeaderSection(context, homeData),
                      ListenableBuilder(
                        listenable: homeData,
                        builder: (context, child) =>
                            _buildFeaturedCategoriesSection(context, homeData),
                      ),
                      ListenableBuilder(
                        listenable: homeData,
                        builder: (context, child) {
                          return homeData.isFlashDeal
                              ? _buildFlashDealSection(context, homeData)
                              : const SliverToBoxAdapter(
                                  child: SizedBox.shrink(),
                                );
                        },
                      ),
                      const SliverList(
                        delegate: SliverChildListDelegate.fixed([
                          PhotoWidget(),
                        ]),
                      ),
                      ListenableBuilder(
                        listenable: homeData,
                        builder: (context, child) =>
                            _buildFeaturedProductsSection(context, homeData),
                      ),
                      ListenableBuilder(
                        listenable: homeData,
                        builder: (context, child) =>
                            _buildAllProductsSection(context, homeData),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ListenableBuilder(
                    listenable: homeData,
                    builder: (context, child) =>
                        _buildProductLoadingContainer(context, homeData),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SliverList _buildHeaderSection(BuildContext context, HomePresenter homeData) {
    return SliverList(
      delegate: SliverChildListDelegate([
        if (AppConfig.purchase_code == "") PiratedWidget(homeData: homeData),
        const SizedBox(height: 2),
        const SizedBox(height: 8),
        ListenableBuilder(
          listenable: homeData,
          builder: (context, child) =>
              HomeCarouselSlider(homeData: homeData, context: context),
        ),
        const SizedBox(height: 16),
        ListenableBuilder(
          listenable: homeData,
          builder: (context, child) => _HomeMenu(homeData: homeData),
        ),
        const SizedBox(height: 16),

        ListenableBuilder(
          listenable: homeData,
          builder: (context, child) =>
              HomeBannerOne(context: context, homeData: homeData),
        ),
      ]),
    );
  }

  SliverToBoxAdapter _buildFeaturedCategoriesSection(
    BuildContext context,
    HomePresenter homeData,
  ) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 10.0, 18.0, 0.0),
            child: Text(
              AppLocalizations.of(context)!.featured_categories_ucf,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(
            height: 175,
            child: FeaturedCategoriesWidget(homeData: homeData),
          ),
        ],
      ),
    );
  }

  SliverList _buildFlashDealSection(
    BuildContext context,
    HomePresenter homeData,
  ) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
          child: Text(
            AppLocalizations.of(context)!.flash_deals_ucf,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 10),
        FlashDealBanner(context: context, homeData: homeData),
      ]),
    );
  }

  SliverList _buildFeaturedProductsSection(
    BuildContext context,
    HomePresenter homeData,
  ) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Container(
          height: 305,
          color: const Color(0xffF2F1F6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 0, 0),
                child: Text(
                  AppLocalizations.of(context)!.featured_products_ucf,
                  style: const TextStyle(
                    color: Color(0xff000000),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
                child: FeaturedProductHorizontalListWidget(homeData: homeData),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  SliverList _buildAllProductsSection(
    BuildContext context,
    HomePresenter homeData,
  ) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Container(
          color: const Color(0xffF2F1F6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18.0, 0.0, 20.0, 0.0),
                child: Text(
                  AppLocalizations.of(context)!.all_products_ucf,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              HomeAllProducts2(homeData: homeData),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ]),
    );
  }

  Widget _buildProductLoadingContainer(
    BuildContext context,
    HomePresenter homeData,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: homeData.showAllLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(
          homeData.totalAllProductData == homeData.allProductList.length
              ? AppLocalizations.of(context)!.no_more_products_ucf
              : AppLocalizations.of(context)!.loading_more_products_ucf,
        ),
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _HomeAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0.0,
      centerTitle: false,
      elevation: 0,
      flexibleSpace: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
        child: GestureDetector(
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => const Filter()));
          },
          child: HomeSearchBox(context: context),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HomeMenu extends StatelessWidget {
  final HomePresenter homeData;

  const _HomeMenu({required this.homeData});

  @override
  Widget build(BuildContext context) {
    if (!homeData.isFlashDeal && !homeData.isTodayDeal) {
      return SizedBox(
        height: 40,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: ShimmerHelper().buildHorizontalGridShimmerWithAxisCount(
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
            item_count: 4,
            mainAxisExtent: 40.0,
          ),
        ),
      );
    }

    final List<Map<String, dynamic>> menuItems = _getMenuItems(context);

    return SizedBox(
      height: 40,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        scrollDirection: Axis.horizontal,
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          final Color containerColor = _getContainerColor(index);

          return GestureDetector(
            onTap: item['onTap'],
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              width: 106,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: containerColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    item['image'],
                    color: item['textColor'],
                    height: 16,
                    width: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item['title'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: item['textColor'],
                      fontWeight: FontWeight.w300,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getContainerColor(int index) {
    if (index == 0 && homeData.isTodayDeal) {
      return const Color(0xff000000);
    } else if (index == 1 || (index == 0 && !homeData.isTodayDeal)) {
      return const Color(0xffFF5500);
    } else {
      return const Color(0xffE9EAEB);
    }
  }

  List<Map<String, dynamic>> _getMenuItems(BuildContext context) {
    return [
      if (homeData.isTodayDeal)
        {
          "title": AppLocalizations.of(context)!.todays_deal_ucf,
          "image": "assets/todays_deal.png",
          "onTap": () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TodaysDealProducts()),
          ),
          "textColor": Colors.white,
        },
      if (homeData.isFlashDeal)
        {
          "title": AppLocalizations.of(context)!.flash_deal_ucf,
          "image": "assets/flash_deal.png",
          "onTap": () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FlashDealList()),
          ),
          "textColor": Colors.white,
        },
      {
        "title": AppLocalizations.of(context)!.brands_ucf,
        "image": "assets/brands.png",
        "onTap": () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Filter(selected_filter: "brands"),
          ),
        ),
        "textColor": const Color(0xff263140),
      },
      if (vendor_system.$)
        {
          "title": AppLocalizations.of(context)!.top_sellers_ucf,
          "image": "assets/top_sellers.png",
          "onTap": () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TopSellers()),
          ),
          "textColor": const Color(0xff263140),
        },
    ];
  }
}

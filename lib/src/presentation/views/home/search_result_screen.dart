import 'package:dawn_frontend/src/presentation/widgets/common/custom_top_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/theme/typography.dart';
import '../../../data/storage/secure_storage.dart';
import '../../view_models/home/search_view_model.dart';
import '../../view_models/home/weekly_featured_view_model.dart';
import '../../view_models/language_view_model.dart';
import '../../widgets/common/custom_scaffold.dart';
import '../../widgets/home/search_input_field.dart';
import '../../widgets/home/event_card.dart';
import '../../widgets/home/weekly_featured_card.dart';
import '../../widgets/map/map_location_preview_card.dart';

class SearchResultScreen extends StatefulWidget {
  final String keyword;

  const SearchResultScreen({super.key, required this.keyword});

  @override
  State<StatefulWidget> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.keyword);
    _triggerSearch(widget.keyword);
  }

  Future<void> _triggerSearch(String keyword) async {
    final token = await SecureStorage.getJwt();
    if (!mounted || token == null || keyword.trim().isEmpty) return;

    final vm = context.read<SearchResultViewModel>();
    await vm.fetchSearchResults(keyword, token);
    await vm.searchEventByKeyword(keyword, token);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchResultViewModel>();
    final events = vm.eventResults;
    final locations = vm.locationResults;
    final isLoading = vm.isLoading;
    final locale = Localizations.localeOf(context).languageCode;
    final local = AppLocalizations.of(context)!;

    return CustomScaffold(
      appBar: const CustomTopAppBar(isDark: true),
      resizeToAvoidBottomInset: true, // 키보드에 맞춰 본문 리사이즈
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bottomInset =
                MediaQuery.of(context).viewInsets.bottom; // 키보드 높이
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(), // 내용이 적을 땐 스크롤 안 보이도록
              padding: EdgeInsets.fromLTRB(
                20, // 기존 좌우 패딩 유지
                0,
                20,
                (bottomInset > 0 ? bottomInset : 0) + 16, // ✅ 키보드 높이만큼 여유
              ),
              child: ConstrainedBox(
                // ✅ 최소 높이를 현재 뷰포트(키보드 제외 후)로 강제
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Center(
                      child: SvgPicture.asset(
                        'assets/icons/logo_sub.svg',
                        width: 215,
                        height: 44,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 검색바
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: SizedBox.shrink(), // 자리 맞추기용 (필요 없으면 제거)
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: SearchInputField(
                        controller: _searchController,
                        hintText: null,
                        onChanged: null,
                        onSearchTap: () async {
                          final keyword = _searchController.text.trim();
                          await _triggerSearch(keyword);
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 로딩 상태 (Expanded 제거: 스크롤 컨텍스트에선 필요 없음)
                    if (isLoading)
                      const Center(child: CircularProgressIndicator()),

                    // 이벤트 결과
                    if (!isLoading && events.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          local.events,
                          style: AppTextStyle.bodyText.copyWith(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ✅ 가로 스크롤 높이 명시로 레이아웃 안정
                      SizedBox(
                        height: 270,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                events.map((event) {
                                  return EventCard(
                                    imageUrl: event.eventImage,
                                    title:
                                        locale == 'ko'
                                            ? event.name
                                            : event.nameEng,
                                    tags:
                                        event.keywords
                                            .map(
                                              (kw) =>
                                                  locale == 'ko'
                                                      ? kw.keyword
                                                      : kw.keywordEng,
                                            )
                                            .toList(),
                                    height: 270,
                                    onTap: () {
                                      context.push('/event-detail/${event.id}');
                                    },
                                  );
                                }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],

                    // 장소 결과
                    if (!isLoading && locations.isNotEmpty) ...[
                      Text(
                        local.locations,
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children:
                            locations.map((location) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: MapLocationPreviewCard(
                                  imageUrl: location.locationSimpleImage,
                                  name:
                                      locale == 'ko'
                                          ? location.name
                                          : location.nameEng,
                                  locationId: location.id,
                                ),
                              );
                            }).toList(),
                      ),
                    ],

                    // 검색 결과 없음
                    if (!isLoading && events.isEmpty && locations.isEmpty) ...[
                      const SizedBox(height: 32),
                      SvgPicture.asset(
                        'assets/icons/no_result_icon.svg',
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        local.noSearchResults,
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 60),
                      Text(
                        local.instead_events,
                        style: AppTextStyle.bodyText.copyWith(
                          fontSize: 15,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      Consumer2<WeeklyFeaturedViewModel, LanguageViewModel>(
                        builder: (context, weeklyVm, langVm, _) {
                          final episode = weeklyVm.weekly;
                          if (episode == null) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final locale = langVm.currentLocale.languageCode;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: WeeklyFeaturedCard(
                              imageUrl: episode.eventImage,
                              title: episode.getNameByLocale(locale),
                              tags: episode.getKeywordsByLocale(locale),
                              onTap: () {
                                context.push('/event-detail/${episode.id}');
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

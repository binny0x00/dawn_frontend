import 'package:dawn_frontend/src/core/theme/typography.dart';
import 'package:dawn_frontend/src/core/utils/constants/constants.dart';
import 'package:dawn_frontend/src/presentation/view_models/language_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/language_dropdown.dart';
import '../../widgets/common/custom_scaffold.dart';
import '../../widgets/auth/sign_in_card.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    final langVm = context.watch<LanguageViewModel>();

    return CustomScaffold(
      body: Container(
        padding: const EdgeInsets.fromLTRB(16, 62, 16, 33),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. 언어 선택 드롭다운
            Align(
              alignment: Alignment.topRight,
              child: IntrinsicWidth(
                child: LanguageDropdown(
                  value: langVm.display,
                  onChanged: (v) {
                    setState(() {
                      langVm.changeLanguage(v);
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 43),
            // 2. 로고
            SvgPicture.asset(
              'assets/icons/logo_main.svg',
              width: 239,
              height: 134,
            ),
            const SizedBox(height: 37),
            // 3. 로그인 카드
            const Expanded(
              child: SingleChildScrollView(
                child: SignInCard(),
              ),
            ),
            // 4. 출처
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(Strings.source, style: AppTextStyle.sourceText),
            ),
          ],
        ),
      ),
    );
  }
}

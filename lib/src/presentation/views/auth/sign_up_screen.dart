import 'package:dawn_frontend/src/presentation/widgets/auth/sign_up_card.dart';
import 'package:dawn_frontend/src/presentation/widgets/common/custom_scaffold.dart';
import 'package:dawn_frontend/src/presentation/widgets/common/custom_top_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/constants/constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 51, 16, 33),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // 전체 중앙 정렬
            children: [
              // 1. 뒤로 가기 버튼
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(24), // 리플도 원형 적용
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Material(
                      color: Colors.transparent, // InkWell 리플 보장
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(24),
                        child: Ink(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(
                              0.5,
                            ), // ⬅️ 배경 50% 투명
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white, // ⬅️ 테두리 순수 white
                              width: 1.2,
                            ),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/icons/back_white.svg',
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 2. 로고
              SvgPicture.asset(
                'assets/icons/logo_sub.svg',
                width: 215.03,
                height: 43.61,
              ),
              const SizedBox(height: 68.5),
              // 3. 회원 가입 카드
              const SignUpCard(),
              // 4. 출처
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(Strings.source, style: AppTextStyle.sourceText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/core/di/injection.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/presentation/failure_copy.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/theme/spacing.dart';
import 'package:shopsphere/core/widgets/buttons.dart';
import 'package:shopsphere/core/widgets/inline_banner.dart';
import 'package:shopsphere/core/widgets/orb_backdrop.dart';
import 'package:shopsphere/core/widgets/wordmark.dart';
import 'package:shopsphere/features/auth/domain/validation/credential_validator.dart';
import 'package:shopsphere/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shopsphere/features/auth/presentation/bloc/login_cubit.dart';
import 'package:shopsphere/l10n/l10n.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LoginCubit>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _obscure = true;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<LoginCubit>().submit(
      username: _username.text,
      password: _password.text,
    );
  }

  void _fillDemo() {
    _username.text = 'emilys';
    _password.text = 'emilyspass';
    context.read<LoginCubit>().editing();
  }

  String? _fieldError(CredentialError? error, {required bool isUsername}) {
    final l10n = context.l10n;
    return switch (error) {
      null => null,
      CredentialError.empty =>
        isUsername ? l10n.usernameEmpty : l10n.passwordEmpty,
      CredentialError.tooShort =>
        isUsername
            ? l10n.usernameTooShort(CredentialValidator.minUsernameLength)
            : l10n.passwordTooShort(CredentialValidator.minPasswordLength),
    };
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final expired =
        authState is Unauthenticated &&
        authState.notice == AuthNotice.sessionExpired;

    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          context.read<AuthCubit>().signedIn(state.user);
        }
      },
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 840;
            final form = _FormPanel(
              username: _username,
              password: _password,
              passwordFocus: _passwordFocus,
              obscure: _obscure,
              sessionExpired: expired,
              onToggleObscure: () => setState(() => _obscure = !_obscure),
              onSubmit: _submit,
              onDemo: _fillDemo,
              fieldError: _fieldError,
            );
            if (!wide) {
              return SafeArea(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 232,
                        child: Stack(
                          children: [
                            Positioned.fill(child: OrbCluster()),
                            Positioned(
                              left: Gap.xl,
                              top: Gap.l,
                              child: Wordmark(size: 19),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          Gap.xl,
                          Gap.s,
                          Gap.xl,
                          Gap.xl,
                        ),
                        child: form,
                      ),
                    ],
                  ),
                ),
              );
            }
            return Row(
              children: [
                Expanded(
                  child: ColoredBox(
                    color: context.colors.surfaceContainerLowest,
                    child: const Stack(
                      children: [
                        Positioned.fill(child: OrbCluster()),
                        Positioned(
                          left: Gap.xxl,
                          top: Gap.xl,
                          child: Wordmark(size: 22),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SafeArea(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(Gap.xxl),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: form,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FormPanel extends StatelessWidget {
  const _FormPanel({
    required this.username,
    required this.password,
    required this.passwordFocus,
    required this.obscure,
    required this.sessionExpired,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.onDemo,
    required this.fieldError,
  });

  final TextEditingController username;
  final TextEditingController password;
  final FocusNode passwordFocus;
  final bool obscure;
  final bool sessionExpired;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final VoidCallback onDemo;
  final String? Function(CredentialError? error, {required bool isUsername})
  fieldError;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<LoginCubit>();

    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        final submitting = state is LoginSubmitting;
        final invalid = state is LoginInvalid ? state : null;
        final failure = state is LoginFailure ? state.failure : null;

        return AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.loginHeadline, style: context.text.displaySmall),
              Gap.hs,
              Text(
                l10n.loginSubhead,
                style: context.text.bodyLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              if (sessionExpired && failure == null) ...[
                Gap.hl,
                InlineBanner(
                  icon: Icons.lock_clock_rounded,
                  message: l10n.sessionEndedNotice,
                ),
              ],
              Gap.hxl,
              TextField(
                controller: username,
                enabled: !submitting,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
                autocorrect: false,
                enableSuggestions: false,
                onChanged: (_) => cubit.editing(),
                onSubmitted: (_) => passwordFocus.requestFocus(),
                decoration: InputDecoration(
                  labelText: l10n.usernameLabel,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  errorText: fieldError(
                    invalid?.usernameError,
                    isUsername: true,
                  ),
                ),
              ),
              Gap.hm,
              TextField(
                controller: password,
                focusNode: passwordFocus,
                enabled: !submitting,
                obscureText: obscure,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                autocorrect: false,
                enableSuggestions: false,
                onChanged: (_) => cubit.editing(),
                onSubmitted: (_) => onSubmit(),
                decoration: InputDecoration(
                  labelText: l10n.passwordLabel,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  errorText: fieldError(
                    invalid?.passwordError,
                    isUsername: false,
                  ),
                  suffixIcon: IconButton(
                    tooltip: obscure ? l10n.showPassword : l10n.hidePassword,
                    onPressed: onToggleObscure,
                    icon: Icon(
                      obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: failure == null
                    ? const SizedBox(width: double.infinity)
                    : Padding(
                        padding: const EdgeInsets.only(top: Gap.l),
                        child: InlineBanner(
                          tone: BannerTone.error,
                          message: failure is InvalidCredentialsFailure
                              ? l10n.invalidCredentials
                              : FailureCopy.of(context, failure).message,
                        ),
                      ),
              ),
              Gap.hxl,
              AppButton(
                label: l10n.signIn,
                isLoading: submitting,
                onPressed: onSubmit,
              ),
              Gap.hm,
              Center(
                child: TextButton.icon(
                  onPressed: submitting ? null : onDemo,
                  icon: const Icon(Icons.bolt_rounded, size: 20),
                  label: Text(l10n.useDemoAccount),
                ),
              ),
              Center(
                child: Text(
                  l10n.demoAccountNote,
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

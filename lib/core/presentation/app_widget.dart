import 'package:auto_route/auto_route.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/auth/application/auth_notifier.dart';
import 'package:repo_viewer/auth/shared/providers.dart';
import 'package:repo_viewer/core/presentation/routes/app_router.gr.dart';
import 'package:repo_viewer/core/shared/providers.dart';

final initializationProvider = FutureProvider<Unit>((ref) async {
  await ref.read(sembastProvider).init();
  ref.read(dioProvider)
    ..options = BaseOptions(
      headers: {
        'Accept': 'application/vnd.github.v3.html+json',
      },
    )
    ..interceptors.add(ref.read(oAuth2InterceptorProvider));
  final authNotifier = ref.read(authNotifierProvider.notifier);
  await authNotifier.checkAndUpdateAuthStatus();
  return unit;
});

class AppWidget extends ConsumerWidget {
  final appRouter = AppRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future.delayed(Duration.zero).then((_) {
      ref.listen<AuthState>(authNotifierProvider, (state) {
        state.maybeMap(
          orElse: () {},
          authenticated: (_) {
            appRouter.pushAndPopUntil(
              const StarredReposRoute(),
              predicate: (_) => false,
            );
          },
          unauthenticated: (_) {
            appRouter.pushAndPopUntil(
              const SignInRoute(),
              predicate: (_) => false,
            );
          },
        );
      });
      ref.listen(initializationProvider, (_) {});
    });
    return MaterialApp.router(
      title: 'Repo Viewer',
      routerDelegate: AutoRouterDelegate(appRouter),
      routeInformationParser: appRouter.defaultRouteParser(),
    );
  }
}

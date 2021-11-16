import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/core/presentation/toasts.dart';
import 'package:repo_viewer/github/core/shared/providers.dart';
import 'package:repo_viewer/github/repos/starred_repos/application/starred_repos_notifier.dart';
import 'package:repo_viewer/github/repos/starred_repos/presentation/failure_repo_tile.dart';
import 'package:repo_viewer/github/repos/starred_repos/presentation/loading_repo_tile.dart';
import 'package:repo_viewer/github/repos/starred_repos/presentation/repo_tile.dart';

class PaginatedReposListView extends ConsumerStatefulWidget {
  const PaginatedReposListView({
    Key? key,
  }) : super(key: key);

  @override
  _PaginatedReposListViewState createState() => _PaginatedReposListViewState();
}

class _PaginatedReposListViewState extends ConsumerState<PaginatedReposListView> {
  bool canLoadNextPage = false;
  bool hasAlreadyShownNoConnectionToast = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<StarredReposState>(starredReposNotifierProvider, (state) {
      state.map(
        initial: (_) => canLoadNextPage = true,
        loadInProgress: (_) => canLoadNextPage = false,
        loadFailure: (_) => canLoadNextPage = false,
        loadSuccess: (_) {
          if (!_.repos.isFresh && !hasAlreadyShownNoConnectionToast) {
            hasAlreadyShownNoConnectionToast = true;
            showNoConnectionToast("You're not online. Some information may be outdated", context);
          }
          return canLoadNextPage = _.isNextPageAvailable;
        },
      );
    });
    final state = ref.watch(starredReposNotifierProvider);
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final metrics = notification.metrics;
        final limit = metrics.maxScrollExtent - metrics.viewportDimension / 3;
        if (canLoadNextPage && metrics.pixels >= limit) {
          canLoadNextPage = false;
          ref.read(starredReposNotifierProvider.notifier).getNextStarredReposPage();
        }
        return false;
      },
      child: _PaginatedListView(
        state: state,
      ),
    );
  }
}

class _PaginatedListView extends StatelessWidget {
  const _PaginatedListView({
    Key? key,
    required this.state,
  }) : super(key: key);

  final StarredReposState state;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: state.map(
        initial: (_) => 0,
        loadInProgress: (_) => _.repos.entity.length + _.itemsPerPage,
        loadSuccess: (_) => _.repos.entity.length,
        loadFailure: (_) => _.repos.entity.length + 1,
      ),
      itemBuilder: (context, index) {
        return state.map(
          initial: (_) => Container(),
          loadInProgress: (_) {
            if (index < _.repos.entity.length) {
              return RepoTile(
                repo: _.repos.entity[index],
              );
            }
            return const LoadingRepoTile();
          },
          loadSuccess: (_) => RepoTile(
            repo: _.repos.entity[index],
          ),
          loadFailure: (_) {
            if (index < _.repos.entity.length) {
              return RepoTile(repo: _.repos.entity[index]);
            }
            return FailureRepoTile(
              failure: _.failure,
            );
          },
        );
      },
    );
  }
}

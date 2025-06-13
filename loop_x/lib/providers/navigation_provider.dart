import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationState {
  final bool isNavBarVisible;

  NavigationState({this.isNavBarVisible = true});

  NavigationState copyWith({bool? isNavBarVisible}) {
    return NavigationState(
      isNavBarVisible: isNavBarVisible ?? this.isNavBarVisible,
    );
  }
}

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(NavigationState());

  void showNavBar() {
    state = state.copyWith(isNavBarVisible: true);
  }

  void hideNavBar() {
    state = state.copyWith(isNavBarVisible: false);
  }
}

final navigationProvider = StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  return NavigationNotifier();
});

class ScrollDirectionListener extends StatefulWidget {
  final Widget child;
  final Function(bool) onDirectionChanged;

  const ScrollDirectionListener({
    super.key,
    required this.child,
    required this.onDirectionChanged,
  });

  @override
  State<ScrollDirectionListener> createState() => _ScrollDirectionListenerState();
}

class _ScrollDirectionListenerState extends State<ScrollDirectionListener> {
  late ScrollController _scrollController;
  bool _isScrollingDown = false;
  double _prevScrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset > _prevScrollOffset && !_isScrollingDown) {
      _isScrollingDown = true;
      widget.onDirectionChanged(false);
    } else if (_scrollController.offset < _prevScrollOffset && _isScrollingDown) {
      _isScrollingDown = false;
      widget.onDirectionChanged(true);
    }
    _prevScrollOffset = _scrollController.offset;
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScrollController(
      controller: _scrollController,
      child: widget.child,
    );
  }
}
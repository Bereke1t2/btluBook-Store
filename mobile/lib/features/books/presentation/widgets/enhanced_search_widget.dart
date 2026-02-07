import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/const/ui_const.dart';
import '../../../../core/const/app_typography.dart';

/// Enhanced Search Widget with:
/// - Recent searches (persisted)
/// - Search suggestions
/// - Voice search button (UI only)
/// - Modern glassmorphism design
class EnhancedSearchWidget extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  final List<String>? suggestions;

  const EnhancedSearchWidget({
    super.key,
    required this.controller,
    required this.onSearch,
    this.suggestions,
  });

  @override
  State<EnhancedSearchWidget> createState() => _EnhancedSearchWidgetState();
}

class _EnhancedSearchWidgetState extends State<EnhancedSearchWidget>
    with SingleTickerProviderStateMixin {
  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 5;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;

  final FocusNode _focusNode = FocusNode();
  bool _showOverlay = false;
  List<String> _recentSearches = [];
  
  // Voice Search
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;

  // Default suggestions if none provided
  final List<String> _defaultSuggestions = [
    'Fiction',
    'Sci-Fi',
    'Self Help',
    'Business',
    'Design',
    'Mystery',
  ];

  @override
  void initState() {
    super.initState();
    
    _animController = AnimationController(
      vsync: this,
      duration: UiConst.durationMedium,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOut,
      ),
    );

    _focusNode.addListener(_onFocusChanged);
    _loadRecentSearches();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _onFocusChanged() {
    setState(() => _showOverlay = _focusNode.hasFocus);
    if (_focusNode.hasFocus) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final searches = prefs.getStringList(_recentSearchesKey) ?? [];
    setState(() => _recentSearches = searches);
  }

  Future<void> _saveRecentSearch(String query) async {
    if (query.isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    _recentSearches.remove(query); // Remove if exists
    _recentSearches.insert(0, query); // Add to front
    
    // Limit to max searches
    if (_recentSearches.length > _maxRecentSearches) {
      _recentSearches = _recentSearches.sublist(0, _maxRecentSearches);
    }
    
    await prefs.setStringList(_recentSearchesKey, _recentSearches);
    setState(() {});
  }

  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentSearchesKey);
    setState(() => _recentSearches = []);
  }

  void _onSearchSubmit(String query) {
    if (query.isNotEmpty) {
      _saveRecentSearch(query);
      widget.onSearch(query);
    }
    _focusNode.unfocus();
  }

  Future<void> _onVoiceSearch() async {
    if (!_speechEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech not available')),
      );
      return;
    }

    // Check permission
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) return;
    }

    if (_speechToText.isListening) {
      await _speechToText.stop();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _speechToText.listen(
        onResult: (result) {
          setState(() {
             widget.controller.text = result.recognizedWords;
             // Ensure cursor is at end
             widget.controller.selection = TextSelection.fromPosition(TextPosition(offset: widget.controller.text.length));
          });
          if (result.finalResult) {
            setState(() => _isListening = false);
            widget.onSearch(result.recognizedWords);
            _onSearchSubmit(result.recognizedWords);
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        _buildSearchBar(),
        
        // Search Overlay (suggestions & recent)
        if (_showOverlay) ...[
          const SizedBox(height: 8),
          FadeTransition(
            opacity: _fadeAnimation,
            child: _buildSearchOverlay(),
          ),
        ],
      ],
    );
  }

  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(UiConst.radiusMedium),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: UiConst.blurLight,
          sigmaY: UiConst.blurLight,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: UiConst.glassFill,
            borderRadius: BorderRadius.circular(UiConst.radiusMedium),
            border: Border.all(color: UiConst.glassBorder),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            style: AppTypography.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Search books, authors, topics...',
              hintStyle: AppTypography.hint,
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Colors.white70,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Clear button
                  if (widget.controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                        size: 20,
                      ),
                      onPressed: () {
                        widget.controller.clear();
                        widget.onSearch('');
                        setState(() {});
                      },
                    ),
                  // Voice search button
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: _VoiceSearchButton(onTap: _onVoiceSearch),
                  ),
                ],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
            ),
            onChanged: (value) {
              widget.onSearch(value);
              setState(() {});
            },
            onSubmitted: _onSearchSubmit,
            textInputAction: TextInputAction.search,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchOverlay() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(UiConst.radiusMedium),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: UiConst.blurMedium,
          sigmaY: UiConst.blurMedium,
        ),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 280),
          decoration: BoxDecoration(
            color: UiConst.glassFill,
            borderRadius: BorderRadius.circular(UiConst.radiusMedium),
            border: Border.all(color: UiConst.glassBorder),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recent Searches
                if (_recentSearches.isNotEmpty) ...[
                  _buildSectionHeader(
                    'Recent Searches',
                    onClear: _clearRecentSearches,
                  ),
                  const SizedBox(height: 8),
                  _buildRecentSearches(),
                  const SizedBox(height: 16),
                ],
                
                // Suggestions
                _buildSectionHeader('Suggestions'),
                const SizedBox(height: 8),
                _buildSuggestions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onClear}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTypography.labelMedium.copyWith(
            color: Colors.white54,
          ),
        ),
        if (onClear != null)
          GestureDetector(
            onTap: onClear,
            child: Text(
              'Clear all',
              style: AppTypography.labelSmall.copyWith(
                color: UiConst.amber,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecentSearches() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _recentSearches.map((search) {
        return _SearchChip(
          label: search,
          icon: Icons.history_rounded,
          onTap: () {
            widget.controller.text = search;
            widget.controller.selection = TextSelection.fromPosition(
              TextPosition(offset: search.length),
            );
            widget.onSearch(search);
          },
          onRemove: () {
            setState(() => _recentSearches.remove(search));
            _saveRecentSearchesToPrefs();
          },
        );
      }).toList(),
    );
  }

  Future<void> _saveRecentSearchesToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentSearchesKey, _recentSearches);
  }

  Widget _buildSuggestions() {
    final suggestions = widget.suggestions ?? _defaultSuggestions;
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: suggestions.map((suggestion) {
        return _SearchChip(
          label: suggestion,
          icon: Icons.trending_up_rounded,
          onTap: () {
            widget.controller.text = suggestion;
            widget.controller.selection = TextSelection.fromPosition(
              TextPosition(offset: suggestion.length),
            );
            widget.onSearch(suggestion);
            _saveRecentSearch(suggestion);
          },
        );
      }).toList(),
    );
  }
}

/// Voice search button with ripple animation
class _VoiceSearchButton extends StatefulWidget {
  final VoidCallback onTap;

  const _VoiceSearchButton({required this.onTap});

  @override
  State<_VoiceSearchButton> createState() => _VoiceSearchButtonState();
}

class _VoiceSearchButtonState extends State<_VoiceSearchButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.9).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: UiConst.brandGradient,
                ),
                borderRadius: BorderRadius.circular(UiConst.radiusSmall),
                boxShadow: [
                  BoxShadow(
                    color: UiConst.amber.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.mic_rounded,
                color: Colors.black,
                size: 18,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Search chip widget
class _SearchChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const _SearchChip({
    required this.label,
    required this.icon,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UiConst.radiusRound),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(UiConst.radiusRound),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: Colors.white60),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                ),
              ),
              if (onRemove != null) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onRemove,
                  child: Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ethio_book_store/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:ethio_book_store/features/chat/domain/entities/multiple_questions.dart';
import 'package:ethio_book_store/features/chat/domain/entities/true_false.dart' as tf;
import 'package:ethio_book_store/features/chat/domain/entities/short_answer.dart' as sa;

enum ChatRole { user, assistant }
enum QuizType { multipleChoice, trueFalse, shortAnswer }

class ChatMessage {
  final String id;
  final ChatRole role;
  final String text;
  final DateTime ts;

  ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    DateTime? ts,
  }) : ts = ts ?? DateTime.now();
}

/// Shared glass container
class GlassContainer extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurSigma;
  final Color color;
  final Color borderColor;

  const GlassContainer({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.borderRadius = 14,
    this.blurSigma = 18,
    this.color = const Color(0x33000000),
    this.borderColor = const Color(0x66FFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 36 / 255),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final String bookTitle;
  final bool isStudentBook;
  final String? initialPrompt;

  const ChatPage({
    super.key,
    required this.bookTitle,
    this.isStudentBook = false,
    this.initialPrompt,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with SingleTickerProviderStateMixin {
  final _messages = <ChatMessage>[];
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

  // Animated background
  late final AnimationController _bgController;

  // Bloc
  late final ChatBloc _bloc;
  bool _sheetOpen = false;

  // Palette
  static const Color ink = Color(0xFF0D1B2A);
  static const Color slate = Color(0xFF233542);
  static const Color leather = Color(0xFF3A2F2A);
  static const Color accentGold = Color(0xFFF2C94C);

  @override
  void initState() {
    super.initState();
    _bloc = context.read<ChatBloc>();
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat(reverse: true);
    _primeConversation();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _primeConversation() {
    final intro = ChatMessage(
      id: UniqueKey().toString(),
      role: ChatRole.assistant,
      text: 'Ask me anything about "${widget.bookTitle}". I can summarize chapters, explain concepts, and create practice quizzes.',
    );
    _messages.add(intro);
    if (widget.initialPrompt != null && widget.initialPrompt!.trim().isNotEmpty) {
      _controller.text = widget.initialPrompt!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    final userMsg = ChatMessage(
      id: UniqueKey().toString(),
      role: ChatRole.user,
      text: text,
    );
    setState(() {
      _messages.add(userMsg);
      _sending = true;
      _controller.clear();
    });
    _scrollToBottom();

    if (text.toLowerCase().contains('quiz')) {
      await _chooseQuizTypeAndStart();
      return;
    }

    // Ask backend through BLoC
    _bloc.add(GetChatResponseEvent(text , widget.bookTitle));
  }

  Future<void> _chooseQuizTypeAndStart() async {
    final type = await showModalBottomSheet<QuizType>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) => GlassContainer(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        borderRadius: 24,
        blurSigma: 26,
        color: Colors.white.withValues(alpha: 24 / 255),
        borderColor: Colors.white.withValues(alpha: 66 / 255),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Choose quiz type', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                _QuizTypeTile(
                  icon: Icons.list_alt,
                  label: 'Multiple Choice',
                  onTap: () => Navigator.of(context, rootNavigator: true).pop(QuizType.multipleChoice),
                ),
                _QuizTypeTile(
                  icon: Icons.check_circle_outline,
                  label: 'True / False',
                  onTap: () => Navigator.of(context, rootNavigator: true).pop(QuizType.trueFalse),
                ),
                _QuizTypeTile(
                  icon: Icons.edit_note,
                  label: 'Short Answer',
                  onTap: () => Navigator.of(context, rootNavigator: true).pop(QuizType.shortAnswer),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );

    if (!mounted || type == null) return;

    await _startQuiz(type: type);
  }

  Future<void> _startQuiz({QuizType type = QuizType.multipleChoice}) async {
    if (_sending) return;
    setState(() => _sending = true);
    switch (type) {
      case QuizType.multipleChoice:
        _bloc.add(GetMultipleQuestionsEvent(widget.bookTitle));
        break;
      case QuizType.trueFalse:
        _bloc.add(GetTrueFalseQuestionEvent(widget.bookTitle));
        break;
      case QuizType.shortAnswer:
        _bloc.add(GetShortAnswerQuestionEvent(widget.bookTitle));
        break;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  InputDecoration _glassInputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 26 / 255),
      hintStyle: const TextStyle(color: Colors.white70),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 64 / 255)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Color(0xFFF2C94C), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Curves.easeInOut.transform(_bgController.value);
    final begin = Alignment.lerp(Alignment.bottomLeft, Alignment.topRight, t)!;
    final end = Alignment.lerp(Alignment.topRight, Alignment.bottomLeft, t)!;

    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state) async {
        // Chat response
        if (state is GetChatResponseLoadingState) {
          setState(() => _sending = true);
        } else if (state is GetChatResponseSuccessState) {
          setState(() {
            _messages.add(ChatMessage(
              id: UniqueKey().toString(),
              role: ChatRole.assistant,
              text: state.response,
            ));
            _sending = false;
          });
          _scrollToBottom();
        } else if (state is GetChatResponseFaliurState) {
          setState(() {
            _messages.add(ChatMessage(
              id: UniqueKey().toString(),
              role: ChatRole.assistant,
              text: state.message,
            ));
            _sending = false;
          });
          _scrollToBottom();
        }

        // Multiple choice
        if (state is GetMultipleQuestionsLoadingState) {
          setState(() => _sending = true);
        } else if (state is GetMultipleQuestionsSuccessState) {
          if (_sheetOpen) return;
          _sheetOpen = true;
          await showModalBottomSheet<void>(
            context: context,
            useRootNavigator: true,
            backgroundColor: Colors.transparent,
            useSafeArea: true,
            isScrollControlled: true,
            builder: (_) => GlassContainer(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              borderRadius: 24,
              blurSigma: 26,
              color: Colors.white.withValues(alpha: 24 / 255),
              borderColor: Colors.white.withValues(alpha: 66 / 255),
              child: QuizSheetMultipleChoice(
                questions: state.questions,
                onSubmit: (score, total) {
                  Navigator.of(context, rootNavigator: true).pop();
                  final result = 'Quiz complete: $score/$total correct. Want explanations for any question?';
                  setState(() {
                    _messages.add(ChatMessage(
                      id: UniqueKey().toString(),
                      role: ChatRole.assistant,
                      text: result,
                    ));
                  });
                  _scrollToBottom();
                },
              ),
            ),
          );
          if (mounted) setState(() => _sending = false);
          _sheetOpen = false;
        } else if (state is GetMultipleQuestionsFaliurState) {
          setState(() {
            _messages.add(ChatMessage(
              id: UniqueKey().toString(),
              role: ChatRole.assistant,
              text: state.message.isNotEmpty ? state.message : 'Could not generate a quiz right now.',
            ));
            _sending = false;
          });
          _scrollToBottom();
        }

        // True/False
        if (state is GetTrueFalseQuestionLoadingState) {
          setState(() => _sending = true);
        } else if (state is GetTrueFalseQuestionSuccessState) {
          if (_sheetOpen) return;
          _sheetOpen = true;
          await showModalBottomSheet<void>(
            context: context,
            useRootNavigator: true,
            backgroundColor: Colors.transparent,
            useSafeArea: true,
            isScrollControlled: true,
            builder: (_) => GlassContainer(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              borderRadius: 24,
              blurSigma: 26,
              color: Colors.white.withValues(alpha: 24 / 255),
              borderColor: Colors.white.withValues(alpha: 66 / 255),
              child: QuizSheetTrueFalse(
                questions: state.questions,
                onSubmit: (score, total) {
                  Navigator.of(context, rootNavigator: true).pop();
                  final result = 'True/False complete: $score/$total correct.';
                  setState(() {
                    _messages.add(ChatMessage(
                      id: UniqueKey().toString(),
                      role: ChatRole.assistant,
                      text: result,
                    ));
                  });
                  _scrollToBottom();
                },
              ),
            ),
          );
          if (mounted) setState(() => _sending = false);
          _sheetOpen = false;
        } else if (state is GetTrueFalseQuestionFaliurState) {
          setState(() {
            _messages.add(ChatMessage(
              id: UniqueKey().toString(),
              role: ChatRole.assistant,
              text: state.message.isNotEmpty ? state.message : 'Could not generate a quiz right now.',
            ));
            _sending = false;
          });
          _scrollToBottom();
        }

        // Short Answer
        if (state is GetShortAnswerQuestionLoadingState) {
          setState(() => _sending = true);
        } else if (state is GetShortAnswerQuestionSuccessState) {
          if (_sheetOpen) return;
          _sheetOpen = true;
          await showModalBottomSheet<void>(
            context: context,
            useRootNavigator: true,
            backgroundColor: Colors.transparent,
            useSafeArea: true,
            isScrollControlled: true,
            builder: (_) => GlassContainer(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              borderRadius: 24,
              blurSigma: 26,
              color: Colors.white.withValues(alpha: 24 / 255),
              borderColor: Colors.white.withValues(alpha: 66 / 255),
              child: QuizSheetShortAnswer(
                questions: state.questions,
                onSubmit: (score, total) {
                  Navigator.of(context, rootNavigator: true).pop();
                  final result = 'Short answer complete: $score/$total scored. Want sample answers?';
                  setState(() {
                    _messages.add(ChatMessage(
                      id: UniqueKey().toString(),
                      role: ChatRole.assistant,
                      text: result,
                    ));
                  });
                  _scrollToBottom();
                },
              ),
            ),
          );
          if (mounted) setState(() => _sending = false);
          _sheetOpen = false;
        } else if (state is GetShortAnswerQuestionFaliurState) {
          setState(() {
            _messages.add(ChatMessage(
              id: UniqueKey().toString(),
              role: ChatRole.assistant,
              text: state.message.isNotEmpty ? state.message : 'Could not generate a quiz right now.',
            ));
            _sending = false;
          });
          _scrollToBottom();
        }
      },
      child: Overlay(
        initialEntries: [
          OverlayEntry(
            builder: (ctx) => Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                title: ShaderMask(
                  shaderCallback: (r) => const LinearGradient(
                    colors: [Colors.white, Color(0xFFFFF1CC), Color(0xFFF2C94C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(r),
                  blendMode: BlendMode.srcIn,
                  child: Text(
                    '${widget.bookTitle} • AI Chat',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                actions: [
                  if (widget.isStudentBook)
                    Tooltip(
                      message: 'Start quiz',
                      child: IconButton(
                        onPressed: _sending ? null : () async {
                          await _chooseQuizTypeAndStart();
                        },
                        icon: const Icon(Icons.quiz_outlined, color: Colors.white),
                      ),
                    ),
                ],
              ),
              extendBodyBehindAppBar: true,
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ink, slate, leather],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ).copyWith(
                  gradient: LinearGradient(
                    begin: begin,
                    end: end,
                    colors: const [ink, slate, leather],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                          itemCount: _messages.length + (_sending ? 1 : 0),
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            if (_sending && index == _messages.length) {
                              return const _TypingBubble();
                            }
                            final msg = _messages[index];
                            final isUser = msg.role == ChatRole.user;

                            final bubbleColor = isUser
                                ? Colors.white.withValues(alpha: 26 / 255)
                                : Colors.white.withValues(alpha: 18 / 255);
                            final borderColor = isUser
                                ? accentGold
                                : Colors.white.withValues(alpha: 56 / 255);

                            return Align(
                              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 560),
                                child: GlassContainer(
                                  color: bubbleColor,
                                  borderColor: borderColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  child: SelectableText(
                                    msg.text,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      _HintChips(
                        onSelect: (v) {
                          _controller.text = v;
                          _controller.selection = TextSelection.fromPosition(TextPosition(offset: v.length));
                        },
                      ),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: GlassContainer(
                    borderRadius: 18,
                    blurSigma: 20,
                    color: Colors.white.withValues(alpha: 26 / 255),
                    borderColor: Colors.white.withValues(alpha: 64 / 255),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            minLines: 1,
                            maxLines: 4,
                            style: const TextStyle(color: Colors.white),
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                            decoration: _glassInputDecoration(
                              hint: 'Ask about ${widget.bookTitle}...',
                              icon: Icons.chat_bubble_outline_rounded,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 44,
                          width: 48,
                          child: IconButton.filled(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(accentGold),
                              foregroundColor: WidgetStateProperty.all(Colors.black),
                              shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            ),
                            onPressed: _sending ? null : _sendMessage,
                            icon: const Icon(Icons.send_rounded),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
              floatingActionButton: widget.isStudentBook
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 86, right: 8),
                      child: SafeArea(
                        child: FloatingActionButton.extended(
                          onPressed: _sending ? null : _chooseQuizTypeAndStart,
                          backgroundColor: accentGold,
                          foregroundColor: Colors.black,
                          icon: const Icon(Icons.school_outlined),
                          label: const Text('Quiz me', style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
    _a = CurvedAnimation(parent: _c, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GlassContainer(
        color: Colors.white.withValues(alpha: 18 / 255),
        borderColor: Colors.white.withValues(alpha: 56 / 255),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: AnimatedBuilder(
          animation: _a,
          builder: (context, _) {
            final t = _a.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final phase = (t + i / 3) % 1.0;
                final scale = 0.6 + 0.4 * (phase < 0.5 ? (phase * 2) : (1 - (phase - 0.5) * 2));
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Transform.scale(
                    scale: scale,
                    child: const CircleAvatar(radius: 3.5, backgroundColor: Colors.white70),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

class _HintChips extends StatelessWidget {
  final void Function(String value) onSelect;
  const _HintChips({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final hints = [
      'Give me a summary',
      'Explain chapter 1',
      'Key terms and definitions',
      'Show a worked example',
      'Give me a quiz',
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Row(
        children: hints
            .map((h) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GlassContainer(
                    borderRadius: 999,
                    blurSigma: 12,
                    color: Colors.white.withValues(alpha: 22 / 255),
                    borderColor: Colors.white.withValues(alpha: 56 / 255),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: InkWell(
                      onTap: () => onSelect(h),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFF2C94C), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            h,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _QuizTypeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuizTypeTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 10),
      borderRadius: 16,
      blurSigma: 16,
      color: Colors.white.withValues(alpha: 22 / 255),
      borderColor: Colors.white.withValues(alpha: 56 / 255),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFFF2C94C)),
        title: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white70),
      ),
    );
  }
}

/// Multiple Choice sheet (uses domain entity)
class QuizSheetMultipleChoice extends StatefulWidget {
  final List<MultipleQuestions> questions;
  final void Function(int score, int total) onSubmit;

  const QuizSheetMultipleChoice({
    super.key,
    required this.questions,
    required this.onSubmit,
  });

  @override
  State<QuizSheetMultipleChoice> createState() => _QuizSheetMultipleChoiceState();
}

class _QuizSheetMultipleChoiceState extends State<QuizSheetMultipleChoice> {
  late final List<int?> _selections;
  late final List<bool> _locked;

  @override
  void initState() {
    super.initState();
    _selections = List.filled(widget.questions.length, null);
    _locked = List.filled(widget.questions.length, false);
  }

  bool get _allAnswered => _selections.every((s) => s != null);

  void _submit() {
    int score = 0;
    for (var i = 0; i < widget.questions.length; i++) {
      if (_selections[i] == widget.questions[i].correctIndex) score++;
    }
    widget.onSubmit(score, widget.questions.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Multiple Choice', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: widget.questions.length + 1,
        itemBuilder: (context, index) {
          if (index == widget.questions.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: _allAnswered ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2C94C),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.check),
                  label: const Text('Submit', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            );
          }
          final q = widget.questions[index];
          final sel = _selections[index];
          final locked = _locked[index];
          return GlassContainer(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            borderRadius: 16,
            blurSigma: 16,
            color: Colors.white.withValues(alpha: 20 / 255),
            borderColor: Colors.white.withValues(alpha: 56 / 255),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(q.question, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                for (var i = 0; i < q.options.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: InkWell(
                      onTap: locked ? null : () {
                        setState(() {
                          _selections[index] = i;
                          _locked[index] = true;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: locked
                                ? (i == q.correctIndex ? Colors.greenAccent : (i == sel ? Colors.redAccent : Colors.white30))
                                : Colors.white38,
                          ),
                          color: locked
                              ? (i == q.correctIndex ? Colors.green.withOpacity(0.18) : (i == sel ? Colors.red.withOpacity(0.18) : Colors.white12))
                              : Colors.white12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              locked
                                  ? (i == q.correctIndex
                                      ? Icons.check_circle
                                      : (i == sel ? Icons.cancel : Icons.radio_button_unchecked))
                                  : Icons.radio_button_unchecked,
                              color: locked
                                  ? (i == q.correctIndex ? Colors.greenAccent : (i == sel ? Colors.redAccent : Colors.white70))
                                  : Colors.white70,
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(q.options[i], style: const TextStyle(color: Colors.white))),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (locked && q.explanations.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Explanation: ${q.explanations}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// True/False sheet (uses domain entity)
class QuizSheetTrueFalse extends StatefulWidget {
  final List<tf.TrueFalse> questions;
  final void Function(int score, int total) onSubmit;

  const QuizSheetTrueFalse({
    super.key,
    required this.questions,
    required this.onSubmit,
  });

  @override
  State<QuizSheetTrueFalse> createState() => _QuizSheetTrueFalseState();
}

class _QuizSheetTrueFalseState extends State<QuizSheetTrueFalse> {
  late final List<int?> _selections;

  @override
  void initState() {
    super.initState();
    _selections = List.filled(widget.questions.length, null);
  }

  bool get _allAnswered => _selections.every((s) => s != null);

  void _submit() {
    int score = 0;
    for (var i = 0; i < widget.questions.length; i++) {
      final correctIndex = widget.questions[i].answer.toLowerCase() == 'true' ? 0 : 1;
      if (_selections[i] == correctIndex) score++;
    }
    widget.onSubmit(score, widget.questions.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('True / False', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: widget.questions.length + 1,
        itemBuilder: (context, index) {
          if (index == widget.questions.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: _allAnswered ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2C94C),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.check),
                  label: const Text('Submit', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            );
          }
          final q = widget.questions[index];
          final sel = _selections[index];
          final correctIndex = q.answer.toLowerCase() == 'true' ? 0 : 1;
          return GlassContainer(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            borderRadius: 16,
            blurSigma: 16,
            color: Colors.white.withValues(alpha: 20 / 255),
            borderColor: Colors.white.withValues(alpha: 56 / 255),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(q.question, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(2, (i) {
                    final isCorrect = i == correctIndex;
                    final isSelected = sel == i;
                    final showFeedback = sel != null;
                    final bg = showFeedback
                        ? (isSelected ? (isCorrect ? Colors.green.withOpacity(0.18) : Colors.red.withOpacity(0.18)) : Colors.white12)
                        : Colors.white12;
                    final border = showFeedback
                        ? (isSelected ? (isCorrect ? Colors.greenAccent : Colors.redAccent) : Colors.white38)
                        : Colors.white38;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i == 0 ? 8 : 0),
                        child: InkWell(
                          onTap: () => setState(() => _selections[index] = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: border),
                              color: bg,
                            ),
                            child: Center(
                              child: Text(i == 0 ? 'True' : 'False', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                if (sel != null && q.explanation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Explanation: ${q.explanation}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Short Answer sheet (uses domain entity)
class QuizSheetShortAnswer extends StatefulWidget {
  final List<sa.ShortAnswer> questions;
  final void Function(int score, int total) onSubmit;

  const QuizSheetShortAnswer({
    super.key,
    required this.questions,
    required this.onSubmit,
  });

  @override
  State<QuizSheetShortAnswer> createState() => _QuizSheetShortAnswerState();
}

class _QuizSheetShortAnswerState extends State<QuizSheetShortAnswer> {
  late final List<TextEditingController> _answers;
  late final List<bool> _checked;
  late final List<bool> _corrects;

  @override
  void initState() {
    super.initState();
    _answers = List.generate(widget.questions.length, (_) => TextEditingController());
    _checked = List.filled(widget.questions.length, false);
    _corrects = List.filled(widget.questions.length, false);
  }

  @override
  void dispose() {
    for (final c in _answers) {
      c.dispose();
    }
    super.dispose();
  }

  void _check(int i) {
    final expected = widget.questions[i].answer.toLowerCase().trim();
    final got = _answers[i].text.toLowerCase().trim();
    setState(() {
      _checked[i] = true;
      _corrects[i] = got == expected;
    });
  }

  void _submit() {
    int score = 0;
    for (var i = 0; i < widget.questions.length; i++) {
      if (_corrects[i]) score++;
    }
    widget.onSubmit(score, widget.questions.length);
  }

  @override
  Widget build(BuildContext context) {
    final allChecked = _checked.every((c) => c);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Short Answer', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: widget.questions.length + 1,
        itemBuilder: (context, index) {
          if (index == widget.questions.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: allChecked ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2C94C),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.check),
                  label: const Text('Submit', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            );
          }
          final q = widget.questions[index];
          final checked = _checked[index];
          final correct = _corrects[index];
          return GlassContainer(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            borderRadius: 16,
            blurSigma: 16,
            color: Colors.white.withValues(alpha: 20 / 255),
            borderColor: Colors.white.withValues(alpha: 56 / 255),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(q.question, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                TextField(
                  controller: _answers[index],
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Type your answer…',
                    hintStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 18 / 255),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 56 / 255)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Color(0xFFF2C94C), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: checked ? null : () => _check(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2C94C),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.search),
                      label: const Text('Check'),
                    ),
                    const SizedBox(width: 12),
                    if (checked)
                      Row(
                        children: [
                          Icon(correct ? Icons.check_circle : Icons.cancel, color: correct ? Colors.greenAccent : Colors.redAccent),
                          const SizedBox(width: 6),
                          Text(
                            correct ? 'Correct' : 'Expected: ${q.answer}',
                            style: TextStyle(color: correct ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                  ],
                ),
                if (checked && q.explanation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Explanation: ${q.explanation}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

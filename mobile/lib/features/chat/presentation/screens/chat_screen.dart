import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:gnyaan/core/theme/app_colors.dart';
import 'package:gnyaan/core/theme/app_text_styles.dart';
import 'package:gnyaan/core/constants/app_constants.dart';
import 'package:gnyaan/shared/widgets/glass_card.dart';
import 'package:gnyaan/shared/widgets/app_buttons.dart';
import 'package:gnyaan/features/chat/services/chat_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/source_citation.dart';
import '../widgets/active_doc_selector.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocus = FocusNode();
  final ChatService _chatService = ChatService();
  bool _isTyping = false;
  bool _isStreaming = false;
  String _activeDoc = 'All Documents';

  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    try {
      final history = await _chatService.getChatHistory();
      if (history.isNotEmpty && mounted) {
        setState(() {
          _messages.addAll(history.map((m) => ChatMessage(
                id: m['_id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
                role: m['role'] == 'user' ? MessageRole.user : MessageRole.assistant,
                content: m['text'] as String? ?? '',
                timestamp: m['timestamp'] != null
                    ? DateTime.tryParse(m['timestamp'].toString()) ?? DateTime.now()
                    : DateTime.now(),
                sources: _parseSources(m['sources']),
              )));
        });
        _scrollToBottom();
      }
    } catch (_) {
      // Silent fail — empty chat is fine
    }
  }

  List<ChatSource> _parseSources(dynamic sources) {
    if (sources == null || sources is! List) return [];
    return sources.map<ChatSource>((s) {
      final map = s as Map<String, dynamic>;
      return ChatSource(
        docName: map['documentId']?.toString() ?? 'Source',
        page: 0,
        snippet: '',
        similarity: (map['score'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg800,
      body: Column(
        children: [
          // ── Top bar ────────────────────────────────────────────────────
          _ChatTopBar(
            activeDoc: _activeDoc,
            onDocSwitch: _showDocSelector,
            onClearChat: _clearChat,
          ),

          // ── Active doc badge ─────────────────────────────────────────
          ActiveDocSelector(
            activeDoc: _activeDoc,
            onTap: _showDocSelector,
          ),

          // ── Message list ─────────────────────────────────────────────
          Expanded(
            child: _messages.isEmpty
                ? _EmptyState(onSuggestion: _handleSuggestion)
                : ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPadding,
                        vertical: AppSpacing.lg),
                    itemCount: _messages.length + (_isStreaming ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == _messages.length) {
                        return const _TypingIndicator();
                      }
                      final msg = _messages[i];
                      return MessageBubble(
                        message: msg,
                        isLastMessage: i == _messages.length - 1,
                      );
                    },
                  ),
          ),

          // ── Hallucination guard notice ────────────────────────────────
          _HallucinationGuard(),

          // ── Input Bar ────────────────────────────────────────────────
          _ChatInputBar(
            controller: _inputController,
            focusNode: _inputFocus,
            isStreaming: _isStreaming,
            onSend: _sendMessage,
            onStop: _stopStreaming,
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: MessageRole.user,
        content: text,
        timestamp: DateTime.now(),
        sources: [],
      ));
      _isStreaming = true;
      _inputController.clear();
    });
    _scrollToBottom();

    try {
      final response = await _chatService.sendQuery(text.trim());
      if (mounted) {
        setState(() {
          _isStreaming = false;
          _messages.add(ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            role: MessageRole.assistant,
            content: response['answer'] as String? ?? 'No response received.',
            timestamp: DateTime.now(),
            sources: _parseSources(response['sources']),
          ));
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isStreaming = false;
          _messages.add(ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            role: MessageRole.assistant,
            content: 'Sorry, something went wrong. Please try again.',
            timestamp: DateTime.now(),
            sources: [],
          ));
        });
        _scrollToBottom();
      }
    }
  }

  void _handleSuggestion(String suggestion) {
    _inputController.text = suggestion;
    _inputFocus.requestFocus();
  }

  void _stopStreaming() => setState(() => _isStreaming = false);

  void _clearChat() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bg600,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text('Clear Chat', style: AppTextStyles.h2),
        content: Text(
          'This will remove all messages in this session.',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted),
        ),
        actions: [
          GhostButton(label: 'Cancel', onPressed: () => Navigator.pop(context)),
          PrimaryButton(
            label: 'Clear',
            onPressed: () {
              setState(() => _messages.clear());
              Navigator.pop(context);
            },
            width: 100,
          ),
        ],
      ),
    );
  }

  void _showDocSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DocSelectorSheet(
        current: _activeDoc,
        onSelect: (doc) {
          setState(() => _activeDoc = doc);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: AppDurations.slow,
          curve: Curves.easeOut,
        );
      }
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Top Bar ────────────────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _ChatTopBar extends StatelessWidget {
  const _ChatTopBar({
    required this.activeDoc,
    required this.onDocSwitch,
    required this.onClearChat,
  });

  final String activeDoc;
  final VoidCallback onDocSwitch;
  final VoidCallback onClearChat;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding, 16, AppSpacing.screenPadding, 12),
        child: Row(
          children: [
            // Back
            IconGlassButton(
              icon: LucideIcons.arrowLeft,
              onPressed: () => Navigator.of(context).maybePop(),
              size: 40,
              iconSize: 18,
            ),
            const SizedBox(width: 12),

            // Title block
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('RAG Query Engine', style: AppTextStyles.h3),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat())
                          .fade(begin: 0.3, end: 1.0, duration: 1000.ms),
                      const SizedBox(width: 6),
                      Text('Connected to Claude',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.success)),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            IconGlassButton(
              icon: LucideIcons.refreshCcw,
              onPressed: onClearChat,
              size: 40,
              iconSize: 16,
            ),
            const SizedBox(width: 8),
            IconGlassButton(
              icon: LucideIcons.moreVertical,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chat Settings (Demo)')),
                );
              },
              size: 40,
              iconSize: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Typing Indicator ──────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(LucideIcons.brain,
                size: 16, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.bg600,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: AppColors.border200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Dot(delay: 0),
                const SizedBox(width: 4),
                _Dot(delay: 150),
                const SizedBox(width: 4),
                _Dot(delay: 300),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.delay});
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.brand,
        shape: BoxShape.circle,
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .moveY(
          begin: 0,
          end: -6,
          delay: Duration(milliseconds: delay),
          duration: 400.ms,
          curve: Curves.easeInOut,
        )
        .then()
        .moveY(begin: -6, end: 0, duration: 400.ms, curve: Curves.easeInOut);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Hallucination Guard ───────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _HallucinationGuard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.brand.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.brand.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.shieldCheck,
              size: 13, color: AppColors.brand.withOpacity(0.7)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Answers grounded exclusively in uploaded documents. Similarity threshold: 0.30',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSubtle,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Chat Input Bar ─────────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _ChatInputBar extends StatefulWidget {
  const _ChatInputBar({
    required this.controller,
    required this.focusNode,
    required this.isStreaming,
    required this.onSend,
    required this.onStop,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isStreaming;
  final ValueChanged<String> onSend;
  final VoidCallback onStop;

  @override
  State<_ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<_ChatInputBar> {
  bool _isExploreMode = false;
  bool _isFocused = false;

  void _onFocusChanged() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });
  }

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: AnimatedContainer(
        duration: AppDurations.normal,
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding, 8, AppSpacing.screenPadding, 12),
        decoration: BoxDecoration(
          color: AppColors.bg700,
          border: const Border(top: BorderSide(color: AppColors.border200)),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -10),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Smart Suggestions (only visible on focus)
            AnimatedSize(
              duration: AppDurations.fast,
              alignment: Alignment.bottomCenter,
              child: _isFocused
                  ? Container(
                      height: 40,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          'Summarize this document',
                          'List key concepts',
                          'Explain architecture',
                        ].map((s) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              label: Text(s,
                                  style: AppTextStyles.caption
                                      .copyWith(color: AppColors.brand)),
                              backgroundColor: AppColors.brand.withOpacity(0.1),
                              side: BorderSide(
                                  color: AppColors.brand.withOpacity(0.2)),
                              onPressed: () {
                                widget.controller.text = s;
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // Controls Row (Context & Mode)
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
              child: Row(
                children: [
                  _ControlsChip(
                    icon: LucideIcons.layers,
                    label: 'System Architecture v3',
                    isDropdown: true,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Context Selector (Demo)')),
                      );
                    },
                  ),
                  const Spacer(),
                  _ControlsChip(
                    icon: _isExploreMode ? LucideIcons.globe : LucideIcons.lock,
                    label: _isExploreMode ? 'Explore Mode' : 'Grounded',
                    color: _isExploreMode ? AppColors.warning : AppColors.success,
                    onTap: () {
                      setState(() {
                        _isExploreMode = !_isExploreMode;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Base Input Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconGlassButton(
                  icon: LucideIcons.paperclip,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Attachment Menu (Demo)')),
                    );
                  },
                  size: 44,
                  iconSize: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    decoration: BoxDecoration(
                      color: AppColors.bg500,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border200),
                    ),
                    child: TextField(
                      controller: widget.controller,
                      focusNode: widget.focusNode,
                      style: AppTextStyles.bodyMd,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Ask your documents...',
                        hintStyle: AppTextStyles.bodyMd
                            .copyWith(color: AppColors.textPlaceholder),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                widget.isStreaming
                    ? GestureDetector(
                        onTap: widget.onStop,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: AppColors.error.withOpacity(0.4)),
                          ),
                          child: const Icon(LucideIcons.square,
                              color: AppColors.error, size: 16),
                        ),
                      )
                    : GestureDetector(
                        onTap: () => widget.onSend(widget.controller.text),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: AppColors.brandGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.brand.withOpacity(0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(LucideIcons.send,
                              color: Colors.white, size: 18),
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlsChip extends StatelessWidget {
  const _ControlsChip({
    required this.icon,
    required this.label,
    this.color = AppColors.textMuted,
    this.isDropdown = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isDropdown;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
            if (isDropdown) ...[
              const SizedBox(width: 4),
              Icon(LucideIcons.chevronDown, size: 12, color: color),
            ]
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Empty State ───────────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onSuggestion});
  final ValueChanged<String> onSuggestion;

  static const List<String> _suggestions = [
    'Summarize this document',
    'What are the key concepts?',
    'What does the architecture include?',
    'List all technical specifications',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brand.withOpacity(0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(LucideIcons.messageSquare,
                size: 36, color: Colors.white),
          )
              .animate()
              .scale(
                begin: const Offset(0.8, 0.8),
                curve: Curves.elasticOut,
                duration: 700.ms,
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: 0, end: -4, duration: 2000.ms),
          const SizedBox(height: 24),
          Text('Ask the Engine', style: AppTextStyles.h1),
          const SizedBox(height: 8),
          Text(
            'Your questions are answered directly from\nthe content of your uploaded documents.',
            style: AppTextStyles.bodyMd
                .copyWith(color: AppColors.textMuted, height: 1.7),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Text('Suggested Questions', style: AppTextStyles.labelLg),
          const SizedBox(height: 12),
          ..._suggestions.asMap().entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => onSuggestion(e.value),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bg600,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.border200),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.sparkles,
                          size: 15, color: AppColors.brand),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(e.value, style: AppTextStyles.bodyMd),
                      ),
                      Icon(LucideIcons.arrowRight,
                          size: 14, color: AppColors.iconSubtle),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 100 + e.key * 80))
                  .slideX(begin: 0.2, end: 0),
            );
          }),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Doc Selector Sheet ────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _DocSelectorSheet extends StatelessWidget {
  const _DocSelectorSheet({required this.current, required this.onSelect});
  final String current;
  final ValueChanged<String> onSelect;

  static const List<String> _docs = [
    'System Architecture v3.pdf',
    'Q3 Financial Report.docx',
    'Research Paper — LLMs.pdf',
    'Product Roadmap 2026.txt',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg700,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.border200)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Switch Knowledge Source', style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text(
            'Select which document the AI should search in',
            style: AppTextStyles.bodySm,
          ),
          const SizedBox(height: 20),
          ..._docs.map((doc) {
            final isActive = doc == current;
            return GestureDetector(
              onTap: () => onSelect(doc),
              child: AnimatedContainer(
                duration: AppDurations.normal,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.brand.withOpacity(0.08)
                      : AppColors.bg600,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isActive
                        ? AppColors.brand.withOpacity(0.4)
                        : AppColors.border200,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.brand.withOpacity(0.15)
                            : AppColors.bg500,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        LucideIcons.fileText,
                        size: 16,
                        color: isActive ? AppColors.brand : AppColors.icon,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        doc.replaceAll(RegExp(r'\.(pdf|docx|txt)$', caseSensitive: false), ''),
                        style: AppTextStyles.labelLg.copyWith(
                          color: isActive ? AppColors.brand : AppColors.text,
                        ),
                      ),
                    ),
                    if (isActive)
                      Icon(LucideIcons.checkCircle2,
                          size: 18, color: AppColors.brand),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Data Models ───────────────────────────────────────────────────────────────

enum MessageRole { user, assistant }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    required this.sources,
  });

  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final List<ChatSource> sources;
}

class ChatSource {
  const ChatSource({
    required this.docName,
    required this.page,
    required this.snippet,
    required this.similarity,
  });

  final String docName;
  final int page;
  final String snippet;
  final double similarity;
}

import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../services/ai_service.dart';

class AIChatButton extends StatefulWidget {
  final Future<String> Function(String query)? onQueryAsync;
  final String Function(String query)? onQuery;

  const AIChatButton({super.key, this.onQueryAsync, this.onQuery});

  @override
  State<AIChatButton> createState() => _AIChatButtonState();
}

class _AIChatButtonState extends State<AIChatButton> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: 'Hello Rider! 👋 I\'m Smart Gear AI, your adventure co-pilot.\n\nAsk me anything about cold-weather gear, Himalayan passes, sizing, Ladakh packing lists, or what\'s in stock!',
      isUser: false,
    ),
  ];
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;


  void _sendMessage(String text) async {
    final clean = text.trim();
    if (clean.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: clean, isUser: true));
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    String response;
    if (widget.onQueryAsync != null) {
      response = await widget.onQueryAsync!(clean);
    } else if (widget.onQuery != null) {
      response = widget.onQuery!(clean);
    } else {
      response = await AIService().getChatResponseAsync(clean);
    }

    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add(_ChatMessage(text: response, isUser: false));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.mountainBlue, AppColors.mountainBlueDark],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.sports_motorsports, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Smart Gear AI',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.success),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                'AI Adventure Co-Pilot • Online',
                                style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.slate),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Quick suggestions
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    'Gear for Ladakh?',
                    'Jacket size guide',
                    '7-day packing list',
                    'Do I need thermals?',
                    'What\'s available?',
                  ].map((suggestion) {
                    return GestureDetector(
                      onTap: () => _sendMessage(suggestion),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.mountainBlueLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.mountainBlue.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          suggestion,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.mountainBlue),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isTyping) {
                      return const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.mountainBlue),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Smart Gear AI is analyzing...',
                                style: TextStyle(fontSize: 12, color: AppColors.slate, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    final msg = _messages[index];
                    return _MessageBubble(message: msg);
                  },
                ),
              ),

              // Input
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onSubmitted: _sendMessage,
                        decoration: InputDecoration(
                          hintText: 'Ask about gear, sizing, Ladakh passes...',
                          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: AppColors.mountainBlue, width: 1.5),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceMuted,
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () => _sendMessage(_controller.text),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: const BoxDecoration(
                          color: AppColors.mountainBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppColors.mountainBlue : AppColors.surfaceMuted,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: _MarkdownText(
          text: message.text,
          baseColor: isUser ? Colors.white : AppColors.darkCharcoal,
        ),
      ),
    );
  }
}

/// Lightweight inline markdown renderer — handles **bold**, *italic*, bullet lines
/// and numbered items without any external package.
class _MarkdownText extends StatelessWidget {
  final String text;
  final Color baseColor;

  const _MarkdownText({required this.text, required this.baseColor});

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 4));
        continue;
      }

      // Detect bullet: lines starting with • · - * followed by space
      final bulletMatch = RegExp(r'^\s*([•·\-\*])\s+(.+)$').firstMatch(line);
      final numberedMatch = RegExp(r'^\s*(\d+)\.\s+(.+)$').firstMatch(line);

      if (bulletMatch != null) {
        final content = bulletMatch.group(2) ?? '';
        widgets.add(_BulletLine(content: content, baseColor: baseColor));
      } else if (numberedMatch != null) {
        final num = numberedMatch.group(1) ?? '';
        final content = numberedMatch.group(2) ?? '';
        widgets.add(_NumberedLine(number: num, content: content, baseColor: baseColor));
      } else {
        widgets.add(_InlineText(text: line, baseColor: baseColor));
      }

      if (i < lines.length - 1) widgets.add(const SizedBox(height: 3));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }
}

class _BulletLine extends StatelessWidget {
  final String content;
  final Color baseColor;
  const _BulletLine({required this.content, required this.baseColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5, right: 8),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(shape: BoxShape.circle, color: baseColor.withValues(alpha: 0.7)),
            ),
          ),
          Expanded(child: _InlineText(text: content, baseColor: baseColor)),
        ],
      ),
    );
  }
}

class _NumberedLine extends StatelessWidget {
  final String number;
  final String content;
  final Color baseColor;
  const _NumberedLine({required this.number, required this.content, required this.baseColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. ',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: baseColor, height: 1.45),
          ),
          Expanded(child: _InlineText(text: content, baseColor: baseColor)),
        ],
      ),
    );
  }
}

/// Renders a single line with **bold** and *italic* spans.
class _InlineText extends StatelessWidget {
  final String text;
  final Color baseColor;
  const _InlineText({required this.text, required this.baseColor});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: _parseInlineMarkdown(text, baseColor),
      ),
    );
  }

  List<TextSpan> _parseInlineMarkdown(String source, Color color) {
    final spans = <TextSpan>[];
    // Process **bold** first, then *italic*
    final pattern = RegExp(r'(\*\*(.+?)\*\*|\*(.+?)\*)');
    int last = 0;

    for (final match in pattern.allMatches(source)) {
      if (match.start > last) {
        spans.add(TextSpan(
          text: source.substring(last, match.start),
          style: TextStyle(fontSize: 13.5, color: color, height: 1.5),
        ));
      }
      final full = match.group(0) ?? '';
      final isBold = full.startsWith('**');
      final innerText = isBold ? (match.group(2) ?? '') : (match.group(3) ?? '');
      spans.add(TextSpan(
        text: innerText,
        style: TextStyle(
          fontSize: 13.5,
          color: color,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          fontStyle: isBold ? FontStyle.normal : FontStyle.italic,
          height: 1.5,
        ),
      ));
      last = match.end;
    }

    if (last < source.length) {
      spans.add(TextSpan(
        text: source.substring(last),
        style: TextStyle(fontSize: 13.5, color: color, height: 1.5),
      ));
    }

    if (spans.isEmpty) {
      spans.add(TextSpan(
        text: source,
        style: TextStyle(fontSize: 13.5, color: color, height: 1.5),
      ));
    }

    return spans;
  }
}

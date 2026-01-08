// FILE: lib/ui/screens/chat_screen.dart
// OPIS: Chat interface za AI agente.
// VERZIJA: 2.0 - Quick Response za WiFi/Check-out, poboljšani UX

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// Modeli
import '../../data/models/chat_message.dart';
import '../../data/models/place.dart';

// Servisi
import '../../data/services/gemini_service.dart';
import '../../data/services/places_service.dart';
import '../../data/services/storage_service.dart';

// Widgeti
import '../widgets/place_card.dart';
import '../../utils/translations.dart';

class ChatScreen extends StatefulWidget {
  final String? agentId;
  final String? agentTitle;
  final IconData? agentIcon;
  final Color? agentColor;

  const ChatScreen({
    super.key,
    this.agentId,
    this.agentTitle,
    this.agentIcon,
    this.agentColor,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final List<dynamic> _chatContent = [];
  GeminiService? _geminiService;

  bool _isLoading = false;
  bool _isInit = false;
  bool _isInitializing = true;

  // Podaci o agentu
  late String agentId;
  late String agentTitle;
  late IconData agentIcon;
  late Color agentColor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _initializeChat();
      _isInit = true;
    }
  }

  Future<void> _initializeChat() async {
    // 1. DOHVAT ARGUMENATA IZ RUTE
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    agentId = args?['id'] ?? widget.agentId ?? 'reception';
    agentTitle = args?['title'] ?? widget.agentTitle ?? 'Reception';
    agentIcon = args?['icon'] ?? widget.agentIcon ?? Icons.support_agent;
    agentColor = args?['color'] ?? widget.agentColor ?? const Color(0xFFD4AF37);

    // 2. INICIJALIZACIJA AI SERVISA
    _geminiService = GeminiService(agentId);

    // 3. POZDRAVNA PORUKA (specifična za agenta)
    final greeting = _getAgentGreeting();

    if (mounted) {
      setState(() {
        _chatContent.add(ChatMessage(
          text: greeting,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isInitializing = false;
      });
    }
  }

  String _getAgentGreeting() {
    final guestName = StorageService.getGuestName();
    final personalGreeting =
        guestName.isNotEmpty ? "Hello $guestName! " : "Hello! ";

    switch (agentId) {
      case 'reception':
        return "${personalGreeting}I'm your virtual receptionist. I can help with check-in/out info, WiFi details, house rules, and any questions about your stay. How can I assist you?";

      case 'house':
        return "${personalGreeting}I'm your Smart Home assistant. I can help you with the AC, lights, pool, appliances, and anything else in the property. What do you need help with?";

      case 'gastro':
        return "${personalGreeting}I'm your Gastro & Wine guide! I can recommend the best local restaurants, traditional dishes, and wines. Are you in the mood for seafood, meat, or something local?";

      case 'local':
        return "${personalGreeting}I'm your Local Guide! I know the best beaches, hidden gems, activities, and excursions around here. What would you like to explore?";

      default:
        return "${personalGreeting}How can I help you today?";
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _geminiService == null) return;

    // Dodaj korisnikovu poruku
    setState(() {
      _chatContent.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    // ═══════════════════════════════════════════════════════════════
    // QUICK RESPONSE - Instant odgovor bez API poziva
    // ═══════════════════════════════════════════════════════════════
    final quickResponse = _geminiService!.getQuickResponse(text);

    if (quickResponse != null) {
      // Kratka pauza za prirodniji osjećaj
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        setState(() {
          _chatContent.add(ChatMessage(
            text: quickResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
      return;
    }

    // ═══════════════════════════════════════════════════════════════
    // AI RESPONSE - Poziv Gemini API-ja
    // ═══════════════════════════════════════════════════════════════
    try {
      final response = await _geminiService!.sendMessage(text);

      if (mounted) {
        setState(() {
          _chatContent.add(ChatMessage(
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _chatContent.add(ChatMessage(
            text:
                "I'm sorry, I'm having trouble connecting right now. Please try again.",
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // GOOGLE PLACES PRETRAGA
  // ═══════════════════════════════════════════════════════════════════════
  Future<void> _searchPlaces() async {
    String queryCategory = "point_of_interest";
    String statusMsg = Translations.t('searching_nearby');

    if (agentId == 'gastro') {
      queryCategory = "restaurant";
      statusMsg = "🍽️ ${Translations.t('searching_restaurants')}";
    } else if (agentId == 'local') {
      queryCategory = "tourist_attraction";
      statusMsg = "🗺️ ${Translations.t('searching_attractions')}";
    } else if (agentId == 'reception') {
      queryCategory = "pharmacy";
      statusMsg = "🏥 ${Translations.t('searching_pharmacy')}";
    }

    setState(() {
      _chatContent.add(ChatMessage(
        text: statusMsg,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final places = await PlacesService.searchNearbyPlaces(queryCategory);

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (places.isNotEmpty) {
            // Prvo dodaj kartice
            _chatContent.add(places);
            // Pa onda tekst
            _chatContent.add(ChatMessage(
              text: Translations.t('places_found'),
              isUser: false,
              timestamp: DateTime.now(),
            ));
          } else {
            _chatContent.add(ChatMessage(
              text: Translations.t('no_places_found'),
              isUser: false,
              timestamp: DateTime.now(),
            ));
          }
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _chatContent.add(ChatMessage(
            text: "Search failed. Please check your internet connection.",
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Quick action buttons za česte upite
  void _sendQuickAction(String message) {
    _controller.text = message;
    _sendMessage();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Loading dok se AI inicijalizira
    if (_isInitializing) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: agentColor),
              const SizedBox(height: 20),
              Text(
                "Connecting to $agentTitle...",
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    final bool canSearchMaps =
        agentId == 'gastro' || agentId == 'local' || agentId == 'reception';

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // ═══════════════════════════════════════════════════════
          // QUICK ACTIONS (samo za Reception)
          // ═══════════════════════════════════════════════════════
          if (agentId == 'reception' && _chatContent.length <= 2)
            _buildQuickActions(),

          // ═══════════════════════════════════════════════════════
          // LISTA PORUKA
          // ═══════════════════════════════════════════════════════
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _chatContent.length,
              itemBuilder: (context, index) {
                final item = _chatContent[index];

                if (item is ChatMessage) {
                  return _buildMessageBubble(item);
                } else if (item is List<Place>) {
                  return _buildPlacesList(item);
                }
                return const SizedBox.shrink();
              },
            ),
          ),

          // ═══════════════════════════════════════════════════════
          // LOADING INDIKATOR
          // ═══════════════════════════════════════════════════════
          if (_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: agentColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    Translations.t('thinking'),
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            ),

          // ═══════════════════════════════════════════════════════
          // INPUT POLJE
          // ═══════════════════════════════════════════════════════
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              ),
            ),
            child: Row(
              children: [
                // Map button
                if (canSearchMaps)
                  IconButton(
                    onPressed: _isLoading ? null : _searchPlaces,
                    icon: const Icon(Icons.map),
                    color: _isLoading ? Colors.grey : agentColor,
                    tooltip: Translations.t('find_nearby'),
                  ),

                // Text input
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: const TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: Translations.t('type_message'),
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    enabled: !_isLoading,
                  ),
                ),
                const SizedBox(width: 10),

                // Send button
                FloatingActionButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  backgroundColor: _isLoading ? Colors.grey : agentColor,
                  elevation: 0,
                  mini: true,
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // HELPER WIDGETS
  // ═══════════════════════════════════════════════════════════════════════

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: agentColor.withValues(alpha: 0.1),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: agentColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(agentIcon, color: agentColor, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                agentTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              Text(
                "Online",
                style: TextStyle(
                  color: Colors.green[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      centerTitle: false,
      elevation: 0,
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildQuickChip("📶 WiFi password?", "What's the WiFi password?"),
            _buildQuickChip("🕐 Check-out time?", "What time is check-out?"),
            _buildQuickChip("📋 House rules", "Show me the house rules"),
            _buildQuickChip("📞 Contact host", "How can I contact the host?"),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip(String label, String message) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        labelStyle: const TextStyle(color: Colors.white, fontSize: 13),
        backgroundColor: Colors.white.withValues(alpha: 0.1),
        side: BorderSide(color: agentColor.withValues(alpha: 0.3)),
        onPressed: () => _sendQuickAction(message),
      ),
    );
  }

  Widget _buildPlacesList(List<Place> places) {
    return Container(
      height: 260,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: places.length,
        itemBuilder: (context, index) {
          return PlaceCard(place: places[index]);
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          color: isUser
              ? agentColor.withValues(alpha: 0.85)
              : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 5),
            bottomRight: Radius.circular(isUser ? 5 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isUser
            ? Text(
                msg.text,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              )
            : MarkdownBody(
                data: msg.text,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                      color: Colors.white, fontSize: 16, height: 1.4),
                  strong: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  em: TextStyle(
                    color: Colors.grey[300],
                    fontStyle: FontStyle.italic,
                  ),
                  listBullet: const TextStyle(color: Colors.white),
                  code: TextStyle(
                    backgroundColor: Colors.black.withValues(alpha: 0.3),
                    color: const Color(0xFFD4AF37),
                  ),
                ),
              ),
      ),
    );
  }
}

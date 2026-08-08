// lib/roleplay/screens/create_character_screen.dart
//
// Full-featured bot / character creation screen.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:cortex/app.dart';
import '../../theme.dart';
import '../models/character.dart';
import '../provider.dart';

const _uuid = Uuid();

class CreateCharacterScreen extends StatefulWidget {
  final RoleplayCharacter? editingCharacter;

  const CreateCharacterScreen({super.key, this.editingCharacter});

  @override
  State<CreateCharacterScreen> createState() => _CreateCharacterScreenState();
}

class _CreateCharacterScreenState extends State<CreateCharacterScreen>
    with TickerProviderStateMixin {
  late final TabController _stepController;

  // Form controllers
  final _nameCtrl = TextEditingController();
  final _taglineCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _systemPromptCtrl = TextEditingController();
  final _backgroundCtrl = TextEditingController();
  final _worldCtrl = TextEditingController();

  String _selectedEmoji = '🤖';
  CharacterCategory _selectedCategory = CharacterCategory.original;
  List<PersonalityTrait> _traits = [];
  List<String> _openers = [''];
  List<Color> _gradientColors = [
    const Color(0xFF6C63FF),
    const Color(0xFF3A3A8C),
  ];
  bool _isCreating = false;

  final _nameFormKey = GlobalKey<FormState>();

  static const _stepLabels = [
    'Kimlik',
    'Kişilik',
    'Prompt',
    'Önizleme',
  ];

  static const _presetGradients = [
    [Color(0xFF6C63FF), Color(0xFF3A3A8C)],
    [Color(0xFFFF6B9D), Color(0xFFFFB3CC)],
    [Color(0xFF00BCD4), Color(0xFF006064)],
    [Color(0xFF4CAF50), Color(0xFF1B5E20)],
    [Color(0xFFFF5722), Color(0xFFBF360C)],
    [Color(0xFF9C27B0), Color(0xFF4A148C)],
    [Color(0xFFFFEB3B), Color(0xFFF57F17)],
    [Color(0xFF2196F3), Color(0xFF0D47A1)],
    [Color(0xFFE91E63), Color(0xFF880E4F)],
    [Color(0xFF009688), Color(0xFF004D40)],
  ];



  @override
  void initState() {
    super.initState();
    _stepController = TabController(length: 4, vsync: this);

    // Populate if editing
    if (widget.editingCharacter != null) {
      final c = widget.editingCharacter!;
      _nameCtrl.text = c.name;
      _taglineCtrl.text = c.tagline;
      _descCtrl.text = c.description;
      _systemPromptCtrl.text = c.systemPrompt;
      _backgroundCtrl.text = c.backgroundStory;
      _worldCtrl.text = c.worldContext ?? '';
      _selectedEmoji = c.avatarEmoji;
      _selectedCategory = c.category;
      _traits = List.from(c.traits);
      _openers =
          c.exampleOpeners.isNotEmpty ? List.from(c.exampleOpeners) : [''];
      _gradientColors = List.from(c.gradientColors);
    }
  }

  @override
  void dispose() {
    _stepController.dispose();
    _nameCtrl.dispose();
    _taglineCtrl.dispose();
    _descCtrl.dispose();
    _systemPromptCtrl.dispose();
    _backgroundCtrl.dispose();
    _worldCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          _buildStepIndicator(),
          Expanded(
            child: TabBarView(
              controller: _stepController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1Identity(),
                _buildStep2Personality(),
                _buildStep3Prompt(),
                _buildStep4Preview(),
              ],
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.paddingOf(context).top + 12, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: AnimatedBuilder(
        animation: _stepController,
        builder: (_, __) {
          final step = _stepController.index;
          return Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Icon(Icons.close_rounded,
                      color: AppColors.primaryColor.inverted, size: 18),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.editingCharacter != null
                          ? 'Karakteri Düzenle'
                          : 'Bot Oluştur',
                      style: TextStyle(
                        color: AppColors.primaryColor.inverted,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _stepLabels[step],
                      style: TextStyle(
                        color: AppColors.tertiaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: _gradientColors),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${step + 1}/4',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: AnimatedBuilder(
        animation: _stepController,
        builder: (_, __) {
          return Row(
            children: List.generate(4, (index) {
              final isActive = _stepController.index == index;
              final isCompleted = _stepController.index > index;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index < 3 ? 6 : 0),
                  child: Column(
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: isCompleted || isActive
                              ? null
                              : AppColors.border,
                          gradient: isCompleted || isActive
                              ? LinearGradient(colors: _gradientColors)
                              : null,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _stepLabels[index],
                        style: TextStyle(
                          color: isActive
                              ? AppColors.primaryColor.inverted
                              : AppColors.tertiaryColor,
                          fontSize: 10,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  // ── Step 1: Identity ──────────────────────────────────────────────────────

  Widget _buildStep1Identity() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _nameFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepTitle('Kimlik', 'Karakterinin temel bilgileri'),
            const SizedBox(height: 24),

            // Avatar picker
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickEmoji,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: _gradientColors),
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: _gradientColors.last.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(_selectedEmoji,
                            style: const TextStyle(fontSize: 46)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Avatar seç',
                    style:
                        TextStyle(color: AppColors.tertiaryColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Gradient picker
            _sectionLabel('Renk Teması'),
            const SizedBox(height: 10),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _presetGradients.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final grad = _presetGradients[index];
                  final isSelected = _gradientColors[0] == grad[0];
                  return GestureDetector(
                    onTap: () => setState(() => _gradientColors = grad),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: grad),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Name
            _buildTextField(
              controller: _nameCtrl,
              label: 'İsim *',
              hint: 'Karakterinin adı',
              maxLength: 30,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'İsim boş olamaz' : null,
            ),
            const SizedBox(height: 16),

            // Tagline
            _buildTextField(
              controller: _taglineCtrl,
              label: 'Tagline',
              hint: 'Kısa bir açıklama (ör: Kadim Büyü Ustası)',
              maxLength: 60,
            ),
            const SizedBox(height: 16),

            // Description
            _buildTextField(
              controller: _descCtrl,
              label: 'Açıklama',
              hint: 'Kullanıcıların gördüğü detaylı açıklama...',
              maxLines: 3,
              maxLength: 300,
            ),
            const SizedBox(height: 16),

            // Category
            _sectionLabel('Kategori'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CharacterCategory.values.map((cat) {
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cat.accentColor.withValues(alpha: 0.15)
                          : AppColors.secondaryColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? cat.accentColor : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      cat.label,
                      style: TextStyle(
                        color: isSelected
                            ? cat.accentColor
                            : AppColors.tertiaryColor,
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 2: Personality ───────────────────────────────────────────────────

  Widget _buildStep2Personality() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle('Kişilik', 'Karakterini derinleştir'),
          const SizedBox(height: 24),

          // Traits
          _sectionLabel('Kişilik Özellikleri (max 6)'),
          const SizedBox(height: 10),
          if (_traits.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _traits.map((t) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.senaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.senaryColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(t.emoji, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(t.name,
                          style: TextStyle(
                              color: AppColors.primaryColor.inverted,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => setState(() => _traits.remove(t)),
                        child: Icon(Icons.close_rounded,
                            size: 14, color: AppColors.tertiaryColor),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
          if (_traits.length < 6)
            GestureDetector(
              onTap: _addTrait,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.border, style: BorderStyle.solid),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded,
                        color: AppColors.senaryColor, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Özellik Ekle',
                      style: TextStyle(
                          color: AppColors.senaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),

          // Background story
          _buildTextField(
            controller: _backgroundCtrl,
            label: 'Arka Plan Hikayesi',
            hint: 'Karakterinin geçmişi, nereden geldiği, önemli olaylar...',
            maxLines: 4,
            maxLength: 500,
          ),
          const SizedBox(height: 16),

          // World context
          _buildTextField(
            controller: _worldCtrl,
            label: 'Dünya / Evren',
            hint: 'Karakterinin yaşadığı evren, dönem, lokasyon...',
            maxLines: 3,
            maxLength: 300,
          ),
          const SizedBox(height: 16),

          // Openers
          _sectionLabel('Açılış Cümleleri'),
          Text(
            'Karakterin kullanıcıya söyleyebileceği ilk cümleler',
            style: TextStyle(color: AppColors.tertiaryColor, fontSize: 12),
          ),
          const SizedBox(height: 10),
          ..._openers.asMap().entries.map((entry) {
            final index = entry.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      hint:
                          'Merhaba, ben ${_nameCtrl.text.isNotEmpty ? _nameCtrl.text : "karakter"}...',
                      maxLines: 2,
                      initialValue: _openers[index],
                      onChanged: (v) => _openers[index] = v,
                    ),
                  ),
                  if (_openers.length > 1) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _openers.removeAt(index)),
                      child: Icon(Icons.close_rounded,
                          color: AppColors.tertiaryColor),
                    ),
                  ],
                ],
              ),
            );
          }),
          if (_openers.length < 3)
            TextButton.icon(
              onPressed: () => setState(() => _openers.add('')),
              icon: Icon(Icons.add_rounded, color: AppColors.senaryColor),
              label:
                  Text('Ekle', style: TextStyle(color: AppColors.senaryColor)),
            ),
        ],
      ),
    );
  }

  // ── Step 3: System Prompt ─────────────────────────────────────────────────

  Widget _buildStep3Prompt() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle('Sistem Promptu', 'AI\'ya talimatları ver'),
          const SizedBox(height: 8),

          // Tips card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.senaryColor.withValues(alpha: 0.08),
                  AppColors.quaternaryColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.senaryColor.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.senaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Center(child: Text('💡', style: TextStyle(fontSize: 14))),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'İpuçları',
                      style: TextStyle(
                          color: AppColors.senaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...[
                  'Sen [İsim]\'sin — kim olduğunu ve rolünü açıkla',
                  'KİŞİLİK: özelliklerini maddeler halinde yaz',
                  'KONUŞMA TARZI: nasıl konuştuğunu belirt',
                  'KARAKTERİ KOR — son satırda karakteri koru',
                ].map((tip) => Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.tertiaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tip,
                              style: TextStyle(
                                  color: AppColors.tertiaryColor,
                                  fontSize: 12,
                                  height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Template picker
          _sectionLabel('Şablon ile Başla'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TemplateChip(
                label: '🧙 Fantezi',
                onTap: () => _applyTemplate('fantasy'),
              ),
              _TemplateChip(
                label: '🤗 Arkadaş',
                onTap: () => _applyTemplate('friend'),
              ),
              _TemplateChip(
                label: '🏛️ Tarihi',
                onTap: () => _applyTemplate('historical'),
              ),
              _TemplateChip(
                label: '🚀 Bilim Kurgu',
                onTap: () => _applyTemplate('scifi'),
              ),
              _TemplateChip(
                label: '📚 Eğitici',
                onTap: () => _applyTemplate('educational'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // System prompt textarea
          Container(
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                  child: Row(
                    children: [
                      Text(
                        'Sistem Promptu',
                        style: TextStyle(
                            color: AppColors.tertiaryColor, fontSize: 12),
                      ),
                      const Spacer(),
                      AnimatedBuilder(
                        animation: _systemPromptCtrl,
                        builder: (_, __) {
                          final remaining =
                              3000 - _systemPromptCtrl.text.length;
                          final isWarning = remaining < 200;
                          return Text(
                            '$remaining karakter',
                            style: TextStyle(
                              color: isWarning
                                  ? AppColors.premium
                                  : AppColors.tertiaryColor,
                              fontSize: 11,
                              fontWeight:
                                  isWarning ? FontWeight.w600 : FontWeight.w400,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                TextField(
                  controller: _systemPromptCtrl,
                  maxLines: 14,
                  style: TextStyle(
                      color: AppColors.primaryColor.inverted,
                      fontSize: 14,
                      height: 1.5),
                  decoration: InputDecoration(
                    hintText:
                        'Sen [isim]\'sin...\n\nKİŞİLİK:\n- ...\n\nKONUŞMA TARZI:\n- ...',
                    hintStyle: TextStyle(
                        color: AppColors.tertiaryColor.withValues(alpha: 0.5),
                        fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 4: Preview ───────────────────────────────────────────────────────

  Widget _buildStep4Preview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle('Önizleme', 'Karakterini onaylamaya hazır mısın?'),
          const SizedBox(height: 24),

          // Preview card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _gradientColors,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _gradientColors.last.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: Text(_selectedEmoji,
                            style: const TextStyle(fontSize: 32)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nameCtrl.text.isEmpty
                                ? 'Karakter Adı'
                                : _nameCtrl.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            _taglineCtrl.text.isEmpty
                                ? 'Tagline...'
                                : _taglineCtrl.text,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_descCtrl.text.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    _descCtrl.text,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (_traits.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 6,
                    children: _traits.map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${t.emoji} ${t.name}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _SummaryRow(
                  label: 'Kategori',
                  value: _selectedCategory.label,
                ),
                _SummaryRow(
                  label: 'Kişilik özellikleri',
                  value: '${_traits.length} özellik',
                ),
                _SummaryRow(
                  label: 'Sistem promptu',
                  value: '${_systemPromptCtrl.text.length} karakter',
                ),
                _SummaryRow(
                  label: 'Açılış cümleleri',
                  value: '${_openers.where((o) => o.isNotEmpty).length} adet',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Create button
          GestureDetector(
            onTap: _isCreating ? null : _createCharacter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 56,
              decoration: BoxDecoration(
                gradient: _isCreating
                    ? null
                    : LinearGradient(colors: _gradientColors),
                color: _isCreating ? AppColors.secondaryColor : null,
                borderRadius: BorderRadius.circular(16),
                boxShadow: _isCreating
                    ? null
                    : [
                        BoxShadow(
                          color: _gradientColors.last.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
              ),
              child: Center(
                child: _isCreating
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.primaryColor.inverted,
                        ),
                      )
                    : Text(
                        widget.editingCharacter != null
                            ? 'Değişiklikleri Kaydet'
                            : 'Karakteri Oluştur',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.paddingOf(context).bottom + 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: AnimatedBuilder(
        animation: _stepController,
        builder: (_, __) {
          final step = _stepController.index;
          return Row(
            children: [
              if (step > 0)
                Expanded(
                  child: GestureDetector(
                    onTap: _prevStep,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back_rounded,
                                size: 16,
                                color: AppColors.primaryColor.inverted),
                            const SizedBox(width: 4),
                            Text(
                              'Geri',
                              style: TextStyle(
                                  color: AppColors.primaryColor.inverted,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (step > 0) const SizedBox(width: 12),
              if (step < 3)
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _nextStep,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: _gradientColors),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _gradientColors.last.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Devam',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_rounded,
                                color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  void _nextStep() {
    if (_stepController.index == 0) {
      if (!(_nameFormKey.currentState?.validate() ?? true)) return;
    }
    if (_stepController.index < 3) {
      _stepController.animateTo(_stepController.index + 1);
    }
  }

  void _prevStep() {
    if (_stepController.index > 0) {
      _stepController.animateTo(_stepController.index - 1);
    }
  }

  void _pickEmoji() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _EmojiPicker(
        selected: _selectedEmoji,
        onSelected: (e) {
          setState(() => _selectedEmoji = e);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _addTrait() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _TraitAddSheet(
        usedEmojis: _traits.map((t) => t.emoji).toList(),
        onAdd: (trait) {
          setState(() => _traits.add(trait));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _applyTemplate(String type) {
    final name = _nameCtrl.text.isNotEmpty ? _nameCtrl.text : '[İsim]';
    String template;
    switch (type) {
      case 'fantasy':
        template = '''Sen $name'sin — kadim bir büyü ustası / şövalye / büyücü.

KİŞİLİK:
- Bilge ve sabırlı. Yüzyıllardır yaşamış deneyim sahibisin.
- Gizemli konuşursun; gerçeği doğrudan söylemek yerine ima edersin.
- Büyü ve doğaya derin saygın var.

KONUŞMA TARZI:
- "Kadim yazılar bize der ki..." tarzı açılışlar.
- Ortamı betimlersin: mumların ışığı, pergelerin sesi.
- Kullanıcıya "genç yolcu" dersin.

KARAKTERİ KOR.''';
        break;
      case 'friend':
        template = '''Sen $name'sin — sıcak, anlayışlı ve dürüst bir arkadaş.

KİŞİLİK:
- Gerçekten ilgileniyorsun: soru sorarsın, detayları hatırlarsın.
- Empatik ama yaltakçı değilsin; kendi fikrin var.
- Zaman zaman şakacı ve hafif ironik ama asla incitmezsin.

KONUŞMA TARZI:
- Doğal ve akıcı dil.
- "Hmm, ilginç..." gibi düşünme sesleri.
- Dialog odaklı; uzun monologlardan kaçın.

KARAKTERİ KOR.''';
        break;
      case 'historical':
        template =
            '''Sen $name'sin — tarihte gerçekten yaşamış önemli bir figürsün.

KİŞİLİK:
- Kendi dönemine özgü dünya görüşün var.
- Gerçek görüşlerini ve fikirlerini yansıtırsın.
- Dönemin diliyle konuşursun ama anlaşılır olursun.

KONUŞMA TARZI:
- Kendi döneminin laboratuvarında / sarayında / atölyesinde konuşursun gibi.
- Gerçek tarihi olayları referans alırsın.

KARAKTERİ KOR.''';
        break;
      case 'scifi':
        template =
            '''Sen $name'sin — gelecekte veya başka bir gezegende yaşayan bir karakter.

KİŞİLİK:
- Teknoloji ve bilime hakimsin.
- İnsan doğasını dışarıdan gözlemleyen bir perspektifin var.
- Geleceğin argosunu kullanırsın.

KONUŞMA TARZI:
- Teknolojik terimler: "algoritma", "protokol", "matris".
- Neon ve hologram dolu bir şehri betimlersin.
- Soru sormayı seversin.

KARAKTERİ KOR.''';
        break;
      case 'educational':
        template =
            '''Sen $name'sin — bilgisini paylaşmaktan heyecan duyan bir uzman.

KİŞİLİK:
- Her konuyu analoji ve metaforlarla anlatmayı seversin.
- Öğrencine soruyla geri dönmekten hoşlanırsın.
- Yanlışları nazikçe düzeltirsin.

KONUŞMA TARZI:
- "Harika soru! Şimdi düşün..."
- Karmaşık konular için sıradan örnekler kullan.
- Seviyelere ayır: "basit / derin versiyon".

KARAKTERİ KOR.''';
        break;
      default:
        return;
    }
    setState(() => _systemPromptCtrl.text = template);
  }

  Future<void> _createCharacter() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _stepController.animateTo(0);
      return;
    }

    setState(() => _isCreating = true);

    final character = RoleplayCharacter(
      id: widget.editingCharacter?.id ?? _uuid.v4(),
      name: _nameCtrl.text.trim(),
      tagline: _taglineCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      systemPrompt: _systemPromptCtrl.text.trim(),
      avatarEmoji: _selectedEmoji,
      category: _selectedCategory,
      traits: _traits,
      exampleOpeners: _openers.where((o) => o.trim().isNotEmpty).toList(),
      backgroundStory: _backgroundCtrl.text.trim(),
      worldContext:
          _worldCtrl.text.trim().isEmpty ? null : _worldCtrl.text.trim(),
      isOfficial: false,
      createdAt: widget.editingCharacter?.createdAt ?? DateTime.now(),
      gradientColors: _gradientColors,
      creatorName: 'Ben',
    );

    final rp = context.read<RoleplayProvider>();
    if (widget.editingCharacter != null) {
      await rp.updateCharacter(character);
    } else {
      await rp.createCharacter(character);
    }

    if (mounted) {
      setState(() => _isCreating = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.editingCharacter != null
                ? '✓ Karakter güncellendi'
                : '✓ ${character.name} oluşturuldu!',
          ),
          backgroundColor: AppColors.secondaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _stepTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.primaryColor.inverted,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(color: AppColors.tertiaryColor, fontSize: 13),
        ),
      ],
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        color: AppColors.primaryColor.inverted,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    String? label,
    String? hint,
    int? maxLength,
    int maxLines = 1,
    String? Function(String?)? validator,
    String? initialValue,
    ValueChanged<String>? onChanged,
  }) {
    final field = controller != null
        ? TextFormField(
            controller: controller,
            maxLines: maxLines,
            maxLength: maxLength,
            validator: validator,
            onChanged: onChanged,
            style:
                TextStyle(color: AppColors.primaryColor.inverted, fontSize: 14),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              labelStyle: TextStyle(color: AppColors.tertiaryColor),
              hintStyle: TextStyle(
                  color: AppColors.tertiaryColor.withValues(alpha: 0.5),
                  fontSize: 13),
              filled: true,
              fillColor: AppColors.secondaryColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: AppColors.senaryColor, width: 1.5),
              ),
            ),
          )
        : TextFormField(
            initialValue: initialValue,
            maxLines: maxLines,
            onChanged: onChanged,
            style:
                TextStyle(color: AppColors.primaryColor.inverted, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                  color: AppColors.tertiaryColor.withValues(alpha: 0.5),
                  fontSize: 13),
              filled: true,
              fillColor: AppColors.secondaryColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: AppColors.senaryColor, width: 1.5),
              ),
            ),
          );

    return label != null && controller != null ? field : field;
  }
}

// ── Supporting Widgets ─────────────────────────────────────────────────────

class _TemplateChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TemplateChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: AppColors.primaryColor.inverted,
              fontSize: 13,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(Icons.circle_rounded,
              size: 5, color: AppColors.tertiaryColor),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(color: AppColors.tertiaryColor, fontSize: 13)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.quaternaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(value,
                style: TextStyle(
                    color: AppColors.primaryColor.inverted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _EmojiPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  static const _emojis = [
    '🤖',
    '🧙‍♀️',
    '🕵️',
    '⚔️',
    '🌸',
    '🔭',
    '⚡',
    '🌙',
    '🌿',
    '👾',
    '🦊',
    '🐉',
    '🧝',
    '👸',
    '🤠',
    '🦸',
    '🧟',
    '👻',
    '🎭',
    '🌺',
    '🦋',
    '🌊',
    '🔥',
    '❄️',
    '🌟',
    '💎',
    '🗡️',
    '🎸',
    '🎨',
    '📖',
    '🎪',
    '🦄',
    '🐺',
    '🦁',
    '🐻',
    '🦅',
    '🦉',
    '🐬',
    '🦈',
    '🌙',
    '☠️',
    '🧛',
    '🧜',
    '🧚',
    '🏴‍☠️',
    '🥷',
    '🕶️',
    '👩‍🚀',
    '👨‍🔬',
    '🧑‍🎨',
  ];

  const _EmojiPicker({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 16),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                childAspectRatio: 1,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: _emojis.length,
              itemBuilder: (context, index) {
                final e = _emojis[index];
                return GestureDetector(
                  onTap: () => onSelected(e),
                  child: Container(
                    decoration: BoxDecoration(
                      color: e == selected
                          ? AppColors.senaryColor.withValues(alpha: 0.2)
                          : AppColors.secondaryColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: e == selected
                            ? AppColors.senaryColor
                            : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: Text(e, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom + 8),
        ],
      ),
    );
  }
}

class _TraitAddSheet extends StatefulWidget {
  final List<String> usedEmojis;
  final ValueChanged<PersonalityTrait> onAdd;

  const _TraitAddSheet({required this.usedEmojis, required this.onAdd});

  @override
  State<_TraitAddSheet> createState() => _TraitAddSheetState();
}

class _TraitAddSheetState extends State<_TraitAddSheet> {
  final _nameCtrl = TextEditingController();
  String _selectedEmoji = '✨';

  static const _emojis = [
    '✨',
    '💪',
    '🧠',
    '💜',
    '🔥',
    '❄️',
    '⚡',
    '🌟',
    '🦁',
    '🐺',
    '⚖️',
    '🛡️',
    '🎭',
    '📜',
    '🌿',
    '💎',
    '🎵',
    '🔮',
    '🌊',
    '☀️',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.paddingOf(context).bottom + 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Özellik Ekle',
            style: TextStyle(
                color: AppColors.primaryColor.inverted,
                fontSize: 18,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),

          // Emoji row
          SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _emojis.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final e = _emojis[index];
                final isSelected = e == _selectedEmoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = e),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.senaryColor.withValues(alpha: 0.2)
                          : AppColors.secondaryColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.senaryColor
                            : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: Text(e, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _nameCtrl,
            style: TextStyle(color: AppColors.primaryColor.inverted),
            decoration: InputDecoration(
              hintText: 'Özellik adı (ör: Cesur, Bilge, Gizemli)',
              hintStyle: TextStyle(color: AppColors.tertiaryColor),
              filled: true,
              fillColor: AppColors.secondaryColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.senaryColor),
              ),
            ),
          ),
          const SizedBox(height: 16),

          GestureDetector(
            onTap: () {
              if (_nameCtrl.text.trim().isEmpty) return;
              widget.onAdd(PersonalityTrait(
                name: _nameCtrl.text.trim(),
                emoji: _selectedEmoji,
              ));
            },
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.senaryColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text(
                  'Ekle',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

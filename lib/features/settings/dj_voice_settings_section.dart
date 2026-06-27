import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/audio/dj_tts/dj_tts_config.dart';
import '../../core/audio/dj_tts/dj_tts_key_store.dart';
import '../../core/audio/dj_tts/dj_tts_provider.dart';
import '../../core/storage/settings_providers.dart';
import '../../core/theme/app_theme.dart';

class DjVoiceSettingsSection extends ConsumerStatefulWidget {
  const DjVoiceSettingsSection({super.key});

  @override
  ConsumerState<DjVoiceSettingsSection> createState() =>
      _DjVoiceSettingsSectionState();
}

class _DjVoiceSettingsSectionState extends ConsumerState<DjVoiceSettingsSection> {
  final _openAiKeyController = TextEditingController();
  final _elevenLabsKeyController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _customVoiceIdController = TextEditingController();
  bool _savingOpenAi = false;
  bool _savingElevenLabs = false;
  bool _hasUserOpenAiKey = false;
  bool _hasUserElevenLabsKey = false;

  @override
  void initState() {
    super.initState();
    _instructionsController.text =
        ref.read(appSettingsProvider).djOpenAiInstructions;
    _customVoiceIdController.text =
        ref.read(appSettingsProvider).djElevenLabsVoiceId;
    _loadKeyStatus();
  }

  @override
  void dispose() {
    _openAiKeyController.dispose();
    _elevenLabsKeyController.dispose();
    _instructionsController.dispose();
    _customVoiceIdController.dispose();
    super.dispose();
  }

  Future<void> _loadKeyStatus() async {
    final store = ref.read(djTtsKeyStoreProvider);
    final openAi = await store.hasUserOpenAiKey();
    final eleven = await store.hasUserElevenLabsKey();
    if (!mounted) return;
    setState(() {
      _hasUserOpenAiKey = openAi;
      _hasUserElevenLabsKey = eleven;
    });
  }

  Future<void> _saveOpenAiKey() async {
    setState(() => _savingOpenAi = true);
    try {
      await ref
          .read(djTtsKeyStoreProvider)
          .saveOpenAiKey(_openAiKeyController.text);
      _openAiKeyController.clear();
      await _loadKeyStatus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OpenAI API key saved on this device')),
        );
      }
    } finally {
      if (mounted) setState(() => _savingOpenAi = false);
    }
  }

  Future<void> _saveElevenLabsKey() async {
    setState(() => _savingElevenLabs = true);
    try {
      await ref
          .read(djTtsKeyStoreProvider)
          .saveElevenLabsKey(_elevenLabsKeyController.text);
      _elevenLabsKeyController.clear();
      await _loadKeyStatus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ElevenLabs API key saved on this device'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _savingElevenLabs = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeScope.of(context);
    final settings = ref.watch(appSettingsProvider);
    final provider = settings.djTtsProvider;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'PERSONAL DJ VOICE',
          style: TextStyle(
            color: theme.onSurfaceMuted,
            fontSize: 11,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        _DjCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'TTS provider',
                style: TextStyle(
                  color: theme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how the DJ speaks. Premium providers use your own API key and bill your account.',
                style: TextStyle(
                  color: theme.onSurfaceMuted,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              ...DjTtsProvider.values.map((p) {
                final selected = provider == p;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => ref
                        .read(appSettingsProvider.notifier)
                        .setDjTtsProvider(p),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selected
                            ? theme.accent.withValues(alpha: 0.12)
                            : theme.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? theme.accent.withValues(alpha: 0.45)
                              : theme.onSurface.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            selected
                                ? PhosphorIconsFill.checkCircle
                                : PhosphorIconsRegular.circle,
                            color:
                                selected ? theme.accent : theme.onSurfaceMuted,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  p.label,
                                  style: TextStyle(
                                    color: theme.onSurface,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  p.subtitle,
                                  style: TextStyle(
                                    color: theme.onSurfaceMuted,
                                    fontSize: 11,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              if (provider == DjTtsProvider.openai) ...<Widget>[
                const SizedBox(height: 8),
                _fieldLabel(theme, 'OPENAI API KEY'),
                const SizedBox(height: 8),
                TextField(
                  controller: _openAiKeyController,
                  obscureText: true,
                  autocorrect: false,
                  style: TextStyle(color: theme.onSurface),
                  decoration: _fieldDecoration(
                    theme,
                    hint: _hasUserOpenAiKey
                        ? 'Key saved — paste to replace'
                        : 'sk-...',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _savingOpenAi ? null : _saveOpenAiKey,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.accent,
                          foregroundColor: theme.background,
                          elevation: 0,
                        ),
                        child: _savingOpenAi
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.background,
                                ),
                              )
                            : const Text(
                                'Save key',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                      ),
                    ),
                    if (_hasUserOpenAiKey) ...<Widget>[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () async {
                          await ref
                              .read(djTtsKeyStoreProvider)
                              .clearOpenAiKey();
                          await _loadKeyStatus();
                        },
                        child: Text(
                          'Remove',
                          style: TextStyle(color: theme.onSurfaceMuted),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                _fieldLabel(theme, 'VOICE'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue:
                      DjTtsPresets.openAiVoices.contains(settings.djOpenAiVoice)
                          ? settings.djOpenAiVoice
                          : DjTtsPresets.openAiVoices.first,
                  dropdownColor: theme.surface,
                  style: TextStyle(color: theme.onSurface),
                  decoration: _fieldDecoration(theme, hint: 'Voice'),
                  items: DjTtsPresets.openAiVoices
                      .map(
                        (voice) => DropdownMenuItem<String>(
                          value: voice,
                          child: Text(voice),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    ref
                        .read(appSettingsProvider.notifier)
                        .setDjOpenAiVoice(value);
                  },
                ),
                const SizedBox(height: 12),
                _fieldLabel(theme, 'STYLE INSTRUCTIONS'),
                const SizedBox(height: 8),
                TextField(
                  controller: _instructionsController,
                  maxLines: 3,
                  onChanged: (value) => ref
                      .read(appSettingsProvider.notifier)
                      .setDjOpenAiInstructions(value),
                  style: TextStyle(color: theme.onSurface, fontSize: 13),
                  decoration: _fieldDecoration(
                    theme,
                    hint: 'How the DJ should sound',
                  ),
                ),
              ],
              if (provider == DjTtsProvider.elevenlabs) ...<Widget>[
                const SizedBox(height: 8),
                _fieldLabel(theme, 'ELEVENLABS API KEY'),
                const SizedBox(height: 8),
                TextField(
                  controller: _elevenLabsKeyController,
                  obscureText: true,
                  autocorrect: false,
                  style: TextStyle(color: theme.onSurface),
                  decoration: _fieldDecoration(
                    theme,
                    hint: _hasUserElevenLabsKey
                        ? 'Key saved — paste to replace'
                        : 'xi-...',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            _savingElevenLabs ? null : _saveElevenLabsKey,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.accent,
                          foregroundColor: theme.background,
                          elevation: 0,
                        ),
                        child: _savingElevenLabs
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.background,
                                ),
                              )
                            : const Text(
                                'Save key',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                      ),
                    ),
                    if (_hasUserElevenLabsKey) ...<Widget>[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () async {
                          await ref
                              .read(djTtsKeyStoreProvider)
                              .clearElevenLabsKey();
                          await _loadKeyStatus();
                        },
                        child: Text(
                          'Remove',
                          style: TextStyle(color: theme.onSurfaceMuted),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                _fieldLabel(theme, 'VOICE'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _elevenLabsPresetValue(settings.djElevenLabsVoiceId),
                  dropdownColor: theme.surface,
                  style: TextStyle(color: theme.onSurface),
                  decoration: _fieldDecoration(theme, hint: 'Voice'),
                  items: <DropdownMenuItem<String>>[
                    ...DjTtsPresets.elevenLabsVoices.map(
                      (voice) => DropdownMenuItem<String>(
                        value: voice['id'],
                        child: Text(voice['name']!),
                      ),
                    ),
                    const DropdownMenuItem<String>(
                      value: 'custom',
                      child: Text('Custom voice ID'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    if (value == 'custom') return;
                    _customVoiceIdController.text = value;
                    ref
                        .read(appSettingsProvider.notifier)
                        .setDjElevenLabsVoiceId(value);
                  },
                ),
                if (_elevenLabsPresetValue(settings.djElevenLabsVoiceId) ==
                    'custom') ...<Widget>[
                  const SizedBox(height: 10),
                  TextField(
                    controller: _customVoiceIdController,
                    onChanged: (value) => ref
                        .read(appSettingsProvider.notifier)
                        .setDjElevenLabsVoiceId(value),
                    style: TextStyle(color: theme.onSurface),
                    decoration: _fieldDecoration(theme, hint: 'Voice ID'),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _elevenLabsPresetValue(String voiceId) {
    for (final voice in DjTtsPresets.elevenLabsVoices) {
      if (voice['id'] == voiceId) return voiceId;
    }
    return 'custom';
  }

  Widget _fieldLabel(AppTheme theme, String label) {
    return Text(
      label,
      style: TextStyle(
        color: theme.onSurfaceMuted,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.4,
      ),
    );
  }

  InputDecoration _fieldDecoration(AppTheme theme, {required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: theme.onSurfaceMuted),
      filled: true,
      fillColor: theme.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class _DjCard extends StatelessWidget {
  const _DjCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeScope.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(theme.cardRadius),
        border: Border.all(color: theme.onSurface.withValues(alpha: 0.06)),
      ),
      child: child,
    );
  }
}

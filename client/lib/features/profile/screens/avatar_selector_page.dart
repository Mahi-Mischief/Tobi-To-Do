import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tobi_todo/models/avatar_config.dart';
import 'package:tobi_todo/providers/avatar_provider.dart';
import 'package:tobi_todo/providers/auth_provider.dart';
import 'package:tobi_todo/shared/widgets/avatar_widget.dart';

class AvatarVariantGroup {
  final String baseId; // e.g., assets/avatar/bangs/1
  final List<String> variants; // e.g., [assets/avatar/bangs/1.png, 1b.png]

  AvatarVariantGroup({required this.baseId, required List<String> variants}) : variants = List.unmodifiable(variants);
}

class AvatarSelectorPage extends ConsumerStatefulWidget {
  const AvatarSelectorPage({super.key});

  @override
  ConsumerState<AvatarSelectorPage> createState() => _AvatarSelectorPageState();
}

class _AvatarSelectorPageState extends ConsumerState<AvatarSelectorPage> {
  late AvatarConfig _config;
  bool _loading = true;
  String? _error;
  final Map<String, List<AvatarVariantGroup>> _folderGroups = {};

  @override
  void initState() {
    super.initState();
    _config = ref.read(avatarProvider);
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    try {
      final assets = await _loadManifest();
      final entries = assets.where((k) => k.startsWith('assets/avatar/'));

      debugPrint('Avatar manifest entries: ${entries.length}');
      if (entries.isEmpty) {
        debugPrint('Avatar manifest looks empty. Check pubspec assets and hosting root.');
      }

      final Map<String, List<String>> byFolder = {};
      for (final path in entries) {
        final folder = path.substring(0, path.lastIndexOf('/'));
        byFolder.putIfAbsent(folder, () => []).add(path);
      }

      byFolder.forEach((folder, paths) {
        _folderGroups[folder] = _groupVariants(paths);
      });

      setState(() {
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Failed to load avatar assets: $e';
      });
    }
  }

  Future<List<String>> _loadManifest() async {
    // Modern Flutter web: use binary manifest via AssetManifest API.
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      return manifest.listAssets();
    } catch (_) {
      // Lightweight fallback for older hosts that still emit JSON manifests.
      for (final path in ['AssetManifest.json', 'assets/AssetManifest.json']) {
        try {
          final data = await rootBundle.loadString(path);
          final decoded = jsonDecode(data) as Map<String, dynamic>;
          return decoded.keys.toList();
        } catch (_) {
          // keep trying
        }
      }
      rethrow;
    }
  }

  List<AvatarVariantGroup> _groupVariants(List<String> paths) {
    final regex = RegExp(r'^(.*\/)(\d+)([a-z]*)\.png$');
    final Map<String, List<String>> grouped = {};

    for (final path in paths) {
      final match = regex.firstMatch(path);
      if (match != null) {
        final base = '${match.group(1)}${match.group(2)}';
        grouped.putIfAbsent(base, () => []).add(path);
      } else {
        // Non-numeric extras (e.g., wings/tattoos): treat each file as its own group
        final base = path.replaceAll('.png', '');
        grouped.putIfAbsent(base, () => []).add(path);
      }
    }

    int weight(String p) {
      final m = regex.firstMatch(p);
      if (m == null) return 0;
      final suffix = m.group(3) ?? '';
      if (suffix.isEmpty) return 0;
      return suffix.codeUnitAt(0);
    }

    List<String> variantSort(List<String> list) {
      list.sort((a, b) => weight(a).compareTo(weight(b)));
      return list;
    }

    final groups = grouped.entries.map((e) {
      final variants = variantSort(e.value);
      return AvatarVariantGroup(baseId: e.key, variants: variants);
    }).toList();

    groups.sort((a, b) => _baseNumber(a.baseId).compareTo(_baseNumber(b.baseId)));
    return groups;
  }

  int _baseNumber(String baseId) {
    final m = RegExp(r'^(.*\/)(\d+)$').firstMatch(baseId);
    return m == null ? 0 : int.tryParse(m.group(2)!) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Avatar Builder'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Body'),
              Tab(text: 'Hair'),
              Tab(text: 'Face'),
              Tab(text: 'Clothes'),
              Tab(text: 'Shoes'),
              Tab(text: 'Extras'),
            ],
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 12),
            AvatarWidget(
              key: ValueKey(_config.hashCode),
              config: _config,
              size: 180,
              background: Colors.white,
            )
              .animate()
              .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
            const SizedBox(height: 12),
            if (_loading) const LinearProgressIndicator(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildBodyTab(),
                  _buildHairTab(),
                  _buildFaceTab(),
                  _buildClothesTab(),
                  _buildShoesTab(),
                  _buildExtrasTab(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _config = AvatarConfig.defaults);
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        ref.read(avatarProvider.notifier).setConfig(_config);
                        final auth = ref.read(authProvider).value;
                        if (auth != null) {
                          await ref.read(avatarProvider.notifier).save(auth.id);
                        }
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: _variantGrid(
        folder: 'assets/avatar/body',
        selectedPath: _config.body,
        onSelect: (path) => _config = _config.copyWith(body: path),
      ),
    );
  }

  Widget _buildHairTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hair Back', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _variantGrid(
            folder: 'assets/avatar/hair_back',
            selectedPath: _config.hairBack,
            onSelect: (path) => _config = _config.copyWith(hairBack: path),
          ),
          const SizedBox(height: 12),
          const Text('Hair Front', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _variantGrid(
            folder: 'assets/avatar/hair',
            selectedPath: _config.hairFront,
            onSelect: (path) => _config = _config.copyWith(hairFront: path),
          ),
          const SizedBox(height: 12),
          const Text('Bangs', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _variantGrid(
            folder: 'assets/avatar/bangs',
            selectedPath: _config.bangs,
            onSelect: (path) => _config = _config.copyWith(bangs: path),
          ),
        ],
      ),
    );
  }

  Widget _buildFaceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Eyebrows', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _variantGrid(
            folder: 'assets/avatar/EYEBROWS',
            selectedPath: _config.eyebrows,
            onSelect: (path) => _config = _config.copyWith(eyebrows: path),
          ),
          const SizedBox(height: 12),
          const Text('Eyes', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _variantGrid(
            folder: 'assets/avatar/PUPILS',
            selectedPath: _config.pupils,
            onSelect: (path) => _config = _config.copyWith(pupils: path),
          ),
          const SizedBox(height: 12),
          const Text('Eyelashes', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _variantGrid(
            folder: 'assets/avatar/EYELASHES',
            selectedPath: _config.eyelashes,
            onSelect: (path) => _config = _config.copyWith(eyelashes: path),
          ),
          const SizedBox(height: 12),
          const Text('Mouth', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _variantGrid(
            folder: 'assets/avatar/MOUTH',
            selectedPath: _config.mouth,
            onSelect: (path) => _config = _config.copyWith(mouth: path),
          ),
        ],
      ),
    );
  }

  Widget _buildClothesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tops', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _variantGrid(
            folder: 'assets/avatar/top',
            selectedPath: _config.top,
            onSelect: (path) => _config = _config.copyWith(top: path, dress: ''),
          ),
          const SizedBox(height: 12),
          const Text('Dresses', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _variantGrid(
            folder: 'assets/avatar/dress',
            selectedPath: _config.dress,
            onSelect: (path) => _config = _config.copyWith(dress: path, top: '', bottom: ''),
            allowNone: true,
          ),
          const SizedBox(height: 12),
          const Text('Bottoms', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _variantGrid(
            folder: 'assets/avatar/bottom',
            selectedPath: _config.bottom,
            onSelect: (path) => _config = _config.copyWith(bottom: path, dress: ''),
            allowNone: true,
          ),
        ],
      ),
    );
  }

  Widget _buildShoesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Shoes', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _variantGrid(
            folder: 'assets/avatar/shoes',
            selectedPath: _config.shoes,
            onSelect: (path) => _config = _config.copyWith(shoes: path),
          ),
          const SizedBox(height: 12),
          const Text('Gloves', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _variantGrid(
            folder: 'assets/avatar/gloves',
            selectedPath: _config.gloves,
            onSelect: (path) => _config = _config.copyWith(gloves: path),
            allowNone: true,
          ),
        ],
      ),
    );
  }

  Widget _buildExtrasTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Beards', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _variantGrid(
            folder: 'assets/avatar/BEARD',
            selectedPath: _config.beard,
            onSelect: (path) => _config = _config.copyWith(beard: path),
            allowNone: true,
          ),
          const SizedBox(height: 12),
          const Text('Extras', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _variantGrid(
            folder: 'assets/avatar/extras',
            selectedPath: _config.extras,
            onSelect: (path) => _config = _config.copyWith(extras: path),
            allowNone: true,
          ),
          const SizedBox(height: 12),
          const Text('Hair Bonus (front overlays)', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _variantGrid(
            folder: 'assets/avatar/hair_bonus',
            selectedPath: _config.hairBonus,
            onSelect: (path) => _config = _config.copyWith(hairBonus: path),
            allowNone: true,
          ),
        ],
      ),
    );
  }

  Widget _variantGrid({
    required String folder,
    required String selectedPath,
    required ValueChanged<String> onSelect,
    bool allowNone = false,
  }) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final groups = _folderGroups[folder] ?? [];
    if (groups.isEmpty && allowNone) {
      return _noneTile(selectedPath, onSelect);
    }

    final items = [
      if (allowNone)
        GestureDetector(
          onTap: () => setState(() => onSelect('')),
          child: _card(selectedPath.isEmpty, const Center(child: Text('None', style: TextStyle(fontWeight: FontWeight.w600)))),
        ),
      ...groups.map((g) => _variantTile(g, selectedPath, onSelect)),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: items,
    );
  }

  Widget _variantTile(AvatarVariantGroup group, String selectedPath, ValueChanged<String> onSelect) {
    final selectedVariant = group.variants.contains(selectedPath) ? selectedPath : group.variants.first;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => onSelect(selectedVariant)),
        child: _card(
          selectedPath.startsWith(group.baseId),
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(selectedVariant, fit: BoxFit.contain),
                ),
              ),
              if (group.variants.length > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: group.variants.map((v) {
                      final isVariantSelected = v == selectedVariant;
                      final label = _variantLabel(v, group.baseId);
                      return InkWell(
                        onTap: () => setState(() => onSelect(v)),
                        child: Container(
                          width: 22,
                          height: 22,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isVariantSelected ? Colors.orange : Colors.grey.shade200,
                            shape: BoxShape.circle,
                            border: Border.all(color: isVariantSelected ? Colors.orange : Colors.grey.shade400, width: 1),
                          ),
                          child: Text(label, style: TextStyle(fontSize: 11, color: isVariantSelected ? Colors.white : Colors.black87)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(bool selected, Widget child) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? Colors.orange : Colors.grey.shade300, width: selected ? 2 : 1),
        boxShadow: [
          if (selected)
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: child,
    );
  }

  Widget _noneTile(String selectedPath, ValueChanged<String> onSelect) {
    final isSelected = selectedPath.isEmpty;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => onSelect('')),
        child: _card(isSelected, const Center(child: Text('None', style: TextStyle(fontWeight: FontWeight.w600)))),
      ),
    );
  }

  String _variantLabel(String path, String baseId) {
    final suffix = path.replaceFirst(baseId, '').replaceAll('.png', '');
    if (suffix.isEmpty) return 'A';
    // For extras with non-numeric names, show last token
    if (!RegExp(r'^\d+[a-z]*$', caseSensitive: false).hasMatch(suffix)) {
      final parts = path.split('/');
      final name = parts.isNotEmpty ? parts.last.replaceAll('.png', '') : suffix;
      return name.length > 3 ? name.substring(0, 3).toUpperCase() : name.toUpperCase();
    }
    return suffix.toUpperCase();
  }
}

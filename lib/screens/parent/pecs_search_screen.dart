import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:translator/translator.dart';
import '../../models/arasaac_pictogram.dart';
import '../../services/arasaac_service.dart';

/// Screen for searching and selecting PECS pictograms from ARASAAC
class PecsSearchScreen extends StatefulWidget {
  const PecsSearchScreen({super.key});

  @override
  State<PecsSearchScreen> createState() => _PecsSearchScreenState();
}

class _PecsSearchScreenState extends State<PecsSearchScreen> {
  final ArasaacService _arasaacService = ArasaacService();
  final TextEditingController _searchController = TextEditingController();
  
  List<ArasaacPictogram> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;

  // Suomi-englanti sanakirja yleisimmille aamurutiinisanoille
  final Map<String, String> _translations = {
    // Aamurutiini
    'aamu': 'morning',
    'aamulla': 'morning',
    'aika': 'time',
    'herää': 'wake up',
    'herätä': 'wake up',
    'nouse': 'get up',
    'nousu': 'get up',
    'ylös': 'up',
    
    // Hygienia
    'pese': 'wash',
    'pesu': 'wash',
    'peseydy': 'wash',
    'peseytyminen': 'wash',
    'hampaat': 'teeth',
    'hammas': 'tooth',
    'harjaa': 'brush',
    'harjaus': 'brush',
    'suihku': 'shower',
    'kylpy': 'bath',
    'wc': 'toilet',
    'vessa': 'toilet',
    'potta': 'potty',
    'kädet': 'hands',
    'käsi': 'hand',
    'kasvot': 'face',
    'hiukset': 'hair',
    'saippua': 'soap',
    'pyyhe': 'towel',
    
    // Pukeutuminen
    'pukeudu': 'get dressed',
    'pukeutuminen': 'dress',
    'vaatteet': 'clothes',
    'vaate': 'clothing',
    'paita': 'shirt',
    'housut': 'pants',
    'sukat': 'socks',
    'kengät': 'shoes',
    'kenkä': 'shoe',
    'takki': 'jacket',
    'hattu': 'hat',
    'lapaset': 'mittens',
    'käsineet': 'gloves',
    
    // Ruokailu
    'aamiainen': 'breakfast',
    'lounas': 'lunch',
    'päivällinen': 'dinner',
    'syö': 'eat',
    'syöminen': 'eat',
    'juo': 'drink',
    'juominen': 'drink',
    'ruoka': 'food',
    'vesi': 'water',
    'maito': 'milk',
    'leipä': 'bread',
    'hedelmä': 'fruit',
    'omena': 'apple',
    'banaani': 'banana',
    
    // Toiminnot
    'tee': 'make',
    'sänky': 'bed',
    'petaa': 'make bed',
    'siivoa': 'clean',
    'siivous': 'clean',
    'laukku': 'bag',
    'reppu': 'backpack',
    'koulu': 'school',
    'päiväkoti': 'kindergarten',
    'lähde': 'go',
    'mene': 'go',
    'tule': 'come',
    'odota': 'wait',
    'lopeta': 'stop',
    'jatka': 'continue',
    
    // Tunteet ja tilat
    'iloinen': 'happy',
    'surullinen': 'sad',
    'väsynyt': 'tired',
    'nälkäinen': 'hungry',
    'janoni': 'thirsty',
    
    // Eläimet
    'kissa': 'cat',
    'koira': 'dog',
    'lintu': 'bird',
    'kala': 'fish',
    
    // Värit
    'punainen': 'red',
    'sininen': 'blue',
    'keltainen': 'yellow',
    'vihreä': 'green',
    'musta': 'black',
    'valkoinen': 'white',
  };

  String _translateToEnglish(String text) {
    final lowerText = text.toLowerCase().trim();
    
    // Tarkista suora käännös
    if (_translations.containsKey(lowerText)) {
      return _translations[lowerText]!;
    }
    
    // Etsi osittaisia osumia
    for (var entry in _translations.entries) {
      if (lowerText.contains(entry.key)) {
        return entry.value;
      }
    }
    
    // Jos ei löydy käännöstä, palauta alkuperäinen
    return text;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final searchText = _searchController.text.trim();
    if (searchText.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasSearched = true;
    });

    try {
      final translatedText = _translateToEnglish(searchText);
      print('Searching for: $searchText -> $translatedText');
      final results = await _arasaacService.searchPictograms(
        searchText: translatedText,
        language: 'en',
        bestSearch: true,
      );
      print('Found ${results.length} results');

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      print('Search error: $e');
      setState(() {
        _errorMessage = 'Virhe haettaessa kuvia: $e';
        _isLoading = false;
        _searchResults = [];
      });
    }
  }

  Future<String?> _downloadAndSavePictogram(ArasaacPictogram pictogram) async {
    try {
      // Show loading dialog
      if (!mounted) return null;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Download the image
      final imageBytes = await _arasaacService.downloadPictogramImage(
        id: pictogram.id,
        resolution: 500,
        color: true,
      );

      // Get app directory
      final appDir = await getApplicationDocumentsDirectory();
      final pecsDir = Directory('${appDir.path}/pecs_images');
      if (!await pecsDir.exists()) {
        await pecsDir.create(recursive: true);
      }

      // Save the image
      final fileName = 'arasaac_${pictogram.id}_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = '${pecsDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      if (!mounted) return null;
      Navigator.of(context).pop(); // Close loading dialog

      return filePath;
    } catch (e) {
      if (!mounted) return null;
      Navigator.of(context).pop(); // Close loading dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Virhe tallentaessa kuvaa: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  Future<void> _selectPictogram(ArasaacPictogram pictogram) async {
    final filePath = await _downloadAndSavePictogram(pictogram);
    if (filePath != null && mounted) {
      Navigator.of(context).pop(filePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hae PECS-kuvia'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Hae kuvia (esim. "harjaa hampaita")',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _performSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Hae'),
                ),
              ],
            ),
          ),

          // Help text
          if (!_hasSearched)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_search,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Hae PECS-kuvia ARASAAC-tietokannasta',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kirjoita hakusana ja paina "Hae"',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Loading indicator
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Error message
          if (_errorMessage != null)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

          // Search results
          if (!_isLoading && _errorMessage == null && _hasSearched)
            Expanded(
              child: _searchResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Ei tuloksia',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final pictogram = _searchResults[index];
                        return _PictogramCard(
                          pictogram: pictogram,
                          onSelect: () => _selectPictogram(pictogram),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}

class _PictogramCard extends StatefulWidget {
  final ArasaacPictogram pictogram;
  final VoidCallback onSelect;

  const _PictogramCard({
    required this.pictogram,
    required this.onSelect,
  });

  @override
  State<_PictogramCard> createState() => _PictogramCardState();
}

class _PictogramCardState extends State<_PictogramCard> {
  final translator = GoogleTranslator();
  String? _translatedText;
  bool _isTranslating = false;

  @override
  void initState() {
    super.initState();
    _translateText();
  }

  Future<void> _translateText() async {
    setState(() {
      _isTranslating = true;
    });

    try {
      final translation = await translator.translate(
        widget.pictogram.primaryKeyword,
        from: 'en',
        to: 'fi',
      );
      
      if (mounted) {
        setState(() {
          _translatedText = translation.text;
          _isTranslating = false;
        });
      }
    } catch (e) {
      print('Translation error: $e');
      if (mounted) {
        setState(() {
          _translatedText = widget.pictogram.primaryKeyword; // Fallback
          _isTranslating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: widget.onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  widget.pictogram.getImageUrl(resolution: 500),
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.error_outline, color: Colors.red),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _isTranslating
                  ? const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : Text(
                      _translatedText ?? widget.pictogram.primaryKeyword,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    // TTS functionality disabled - no package installed
  }

  Future<void> speak(String text) async {
    // TTS functionality disabled
    print('TTS would speak: $text');
  }

  Future<void> stop() async {
    // TTS functionality disabled
  }

  Future<void> setLanguage(String language) async {
    // TTS functionality disabled
  }

  Future<void> setSpeechRate(double rate) async {
    // TTS functionality disabled
  }

  Future<void> setVolume(double volume) async {
    // TTS functionality disabled
  }

  Future<void> setPitch(double pitch) async {
    // TTS functionality disabled
  }

  // Apumetodi tehtävän ilmoitukselle
  Future<void> speakTaskNotification(String taskTitle) async {
    print('TTS would announce task: $taskTitle');
  }

  // Tarkista onko TTS käytettävissä
  Future<bool> isLanguageAvailable(String language) async {
    return false; // TTS not available
  }

  void dispose() {
    // Nothing to dispose
  }
}

import 'package:flutter/material.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sovelluksen tiedot'),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // App logo/icon section
          const Center(
            child: Icon(
              Icons.wb_sunny,
              size: 80,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 16),

          // App name and version
          const Center(
            child: Column(
              children: [
                Text(
                  'Aamurutiini',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Versio 1.0.0+1',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Copyright
          _buildSectionCard(
            title: 'Tekijä',
            icon: Icons.copyright,
            children: [
              const Text(
                '© 2025 Henrik Viljanen',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'henrikviljanen.fi',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Description
          _buildSectionCard(
            title: 'Kuvaus',
            icon: Icons.info_outline,
            children: const [
              Text(
                'Aamurutiini on sovellus, joka auttaa lapsia suorittamaan aamun tehtävät itsenäisesti PECS-kuvien (Picture Exchange Communication System) avulla. Sovellus sopii erityisesti autismin kirjon lapsille ja muille lapsille, jotka hyötyvät visuaalisesta tuesta.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Flutter packages
          _buildSectionCard(
            title: 'Käytetyt teknologiat',
            icon: Icons.code,
            children: [
              const Text(
                'Sovellus on kehitetty käyttäen Flutter-kehystä ja seuraavia avoimen lähdekoodin kirjastoja:',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 12),
              _buildPackageList(),
            ],
          ),

          const SizedBox(height: 16),

          // GDPR and Privacy
          _buildSectionCard(
            title: 'Tietosuoja ja GDPR',
            icon: Icons.privacy_tip,
            children: [
              const Text(
                'Tietojen tallennus',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Kaikki tiedot tallennetaan paikallisesti laitteellesi\n'
                '• Sovellus ei lähetä mitään tietoja internetin kautta\n'
                '• Sovellus ei kerää käyttäjätietoja tai analytiikkaa\n'
                '• PECS-kuvat haetaan ARASAAC-tietokannasta (https://arasaac.org)',
                style: TextStyle(fontSize: 14, height: 1.8),
              ),
              const SizedBox(height: 16),
              const Text(
                'Käyttöoikeudet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Tallennustila: Tehtävien ja kuvien tallentamiseen\n'
                '• Kamera/Galleria: PECS-kuvien lisäämiseen tehtäviin\n'
                '• Internet: PECS-kuvien hakemiseen ARASAAC-tietokannasta\n'
                '• Ilmoitukset: Tehtävämuistutusten näyttämiseen',
                style: TextStyle(fontSize: 14, height: 1.8),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tietojen poistaminen',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Voit poistaa kaikki sovelluksen tallentamat tiedot milloin tahansa poistamalla sovelluksen laitteeltasi. Tämä poistaa kaikki tehtävät, asetukset ja ladatut kuvat pysyvästi.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ARASAAC credits
          _buildSectionCard(
            title: 'ARASAAC-kuvapankki',
            icon: Icons.image,
            children: [
              const Text(
                'Sovellus käyttää ARASAAC-kuvapankkia PECS-kuvien lähteenä.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 8),
              const Text(
                'ARASAAC-kuvat ovat lisensoitu Creative Commons BY-NC-SA 3.0 -lisenssillä.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 12),
              const Text(
                'arasaac.org',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // License
          _buildSectionCard(
            title: 'Lisenssi',
            icon: Icons.gavel,
            children: const [
              Text(
                'Tämä sovellus on tarkoitettu henkilökohtaiseen ja ei-kaupalliseen käyttöön. Kaikki oikeudet pidätetään.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.orange),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildPackageList() {
    final packages = [
      'flutter_riverpod: State management',
      'hive & hive_flutter: Local database',
      'flutter_secure_storage: Secure PIN storage',
      'flutter_local_notifications: Task reminders',
      'image_picker: Image selection',
      'path_provider: File storage',
      'just_audio: Sound effects',
      'http: API requests',
      'translator: Finnish translations',
      'uuid: Unique identifiers',
      'intl: Date formatting',
      'timezone: Time zone support',
      'percent_indicator: Progress indicators',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: packages.map((pkg) {
        final parts = pkg.split(': ');
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 14)),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    children: [
                      TextSpan(
                        text: parts[0],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: ': ${parts[1]}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

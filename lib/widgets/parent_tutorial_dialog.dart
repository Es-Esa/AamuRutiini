import 'package:flutter/material.dart';

class ParentTutorialDialog extends StatefulWidget {
  const ParentTutorialDialog({Key? key}) : super(key: key);

  @override
  State<ParentTutorialDialog> createState() => _ParentTutorialDialogState();
}

class _ParentTutorialDialogState extends State<ParentTutorialDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Opastus ${_currentPage + 1}/$_totalPages',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildPage(
                    icon: Icons.waving_hand,
                    color: Colors.blue,
                    title: 'Tervetuloa vanhempien tilaan! 👋',
                    description:
                        'Täällä voit hallita lapsen aamurutiineja.\n\nTämä tutoriaali näyttää sinulle, miten voit:\n\n• Lisätä ja muokata tehtäviä\n• Asettaa äänet\n• Valita PECS-kuvia\n• Muuttaa asetuksia',
                  ),
                  _buildPage(
                    icon: Icons.list_alt,
                    color: Colors.green,
                    title: 'Tehtävien hallinta 📝',
                    description:
                        'Etusivulla näet kaikki tehtävät.\n\n• Paina + -nappia lisätäksesi uuden tehtävän\n• Napauta tehtävää muokataksesi sitä\n• Aseta kullekin tehtävälle:\n  - Nimi\n  - Aloitusaika\n  - Kesto\n  - PECS-kuva',
                  ),
                  _buildPage(
                    icon: Icons.volume_up,
                    color: Colors.orange,
                    title: 'Ääniasetukset 🔊',
                    description:
                        'Voit valita äänet tehtäville:\n\n• Tehtävän aloitus -ääni\n• Tehtävän lopetus -ääni\n• Aikaa jäljellä -muistutus\n• Lähtöaika -hälytys\n\nVoit myös mykistää kaikki äänet yläpalkin kuvakkeesta.',
                  ),
                  _buildPage(
                    icon: Icons.image,
                    color: Colors.purple,
                    title: 'PECS-kuvat 🖼️',
                    description:
                        'ARASAAC-kuvakirjastosta löydät kuvia:\n\n• Etsi suomeksi tai englanniksi\n• Esikatsele kuvaa napauttamalla\n• Valitse kuva tehtävälle\n\nKuvat auttavat lasta ymmärtämään tehtäviä paremmin.',
                  ),
                  _buildPage(
                    icon: Icons.settings,
                    color: Colors.teal,
                    title: 'Asetukset ⚙️',
                    description:
                        'Muita tärkeitä asetuksia:\n\n• Lähtöaika: Aseta aika, jolloin lapsen pitää lähteä\n• PIN-koodi: Vaihda vanhempien tilan PIN-koodi\n• Äänet: Mykistä tai aktivoi äänet\n\nVoit palata lapsitilaan milloin tahansa vasemman yläkulman nuolesta.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _totalPages,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  TextButton(
                    onPressed: _previousPage,
                    child: const Text('Edellinen'),
                  )
                else
                  const SizedBox(width: 80),
                ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    _currentPage < _totalPages - 1 ? 'Seuraava' : 'Aloita',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: color,
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}

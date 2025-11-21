# Aamurutiini - Kehittäjän muistiinpanot

## Ennen ensimmäistä käynnistystä

1. Asenna Flutter riippuvuudet:
```bash
flutter pub get
```

2. Generoi Hive-adapterit:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

3. Lisää placeholder-kuvat (valinnainen):
   - Kopioi PECS-kuvat `assets/pecs/` kansioon
   - Kopioi äänitiedostot `assets/sounds/` kansioon

## Build-komennot

### Android
```bash
# Debug build
flutter run

# Release APK
flutter build apk --release

# App Bundle (Google Play)
flutter build appbundle --release
```

### iOS
```bash
# Debug
flutter run

# Release
flutter build ios --release
```

## Tietokannan tyhjennys (kehitys)

Jos haluat tyhjentää tietokannan testausta varten:

```dart
// Lisää main.dart tiedostoon ennen HiveService.init():
await Hive.deleteBoxFromDisk('tasks');
await Hive.deleteBoxFromDisk('settings');
await Hive.deleteBoxFromDisk('completions');
```

## Ilmoitusten testaus

Android-emulaattorissa:
1. Varmista että "Do not disturb" on pois päältä
2. Salli ilmoitukset sovelluksen asetuksista
3. Testaa välittömiä ilmoituksia:

```dart
await NotificationService().showImmediateNotification(
  title: 'Testi',
  body: 'Toimiiko ilmoitus?',
);
```

## Arkkitehtuuri

### Tiedonkulku

```
UI (Widgets)
    ↕
Providers (Riverpod StateNotifiers)
    ↕
Services (HiveService, NotificationService)
    ↕
Models (MorningTask, AppSettings)
```

### Tilanhallinta

- **tasksProvider**: Lista tehtävistä
- **settingsProvider**: Sovelluksen asetukset
- **taskCompletionsProvider**: Päivän suoritetut tehtävät
- **timeToDepartureProvider**: Reaaliaikainen lähtöön jäävä aika

## Hyödyllisiä debug-komentoja

```bash
# Näytä laitteet
flutter devices

# Puhdista build
flutter clean

# Analysoi koodi
flutter analyze

# Formatoi koodi
flutter format lib/

# Tarkista riippuvuudet
flutter pub outdated
```

## Tyypilliset ongelmat

### "Target of URI doesn't exist" virheet

Ratkaisu: Suorita `flutter pub get`

### Hive-generaattoriongelmat

Ratkaisu: 
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Ilmoitukset eivät toimi

1. Tarkista AndroidManifest.xml oikeudet
2. Varmista timezone-paketin alustus
3. Tarkista notifikaatiokanavat

## Suorituskyvyn optimointi

1. Kuvien pakkaus: Käytä `image`-pakettia kuvien pienentämiseen
2. Laiskaa latausta: Lataa kuvia vain tarvittaessa
3. Välitysmuisti: Hive on nopea, mutta vältä turhia kyselyjä

## Testaus

Testaa eri skenaarioita:
- [ ] Ensimmäinen käynnistys
- [ ] PIN-koodin asetus ja vaihto
- [ ] Tehtävien lisäys, muokkaus, poisto
- [ ] Ilmoitusten ajastus
- [ ] Tehtävien suoritus
- [ ] Offline-toiminnallisuus
- [ ] Kuvien lataus ja tallennus

## Tulevaisuuden parannukset

- Lisää yksikkötestejä
- Widget-testit kriittisille komponenteille
- Integraatiotestit
- CI/CD pipeline
- Lokalisaatio (englanti, ruotsi)

# Aamurutiini - Morning Routine App for Children

Visuaalinen aamurutiinisovellus lapsille PECS-kuvien tuella.

## 📱 Ominaisuudet

### Lapselle
- ✅ Selkeä visuaalinen tehtävälista PECS-kuvilla
- ⏰ Iso ajastin joka näyttää ajan lähtöön
- 📊 Edistymispalkki tehtävien suorittamisesta
- 🎉 Kannustavia animaatioita ja ääniä
- 🖼️ Isot, helppolukuiset kuvakkeet
- 👆 Yksinkertainen "Valmis"-nappi jokaiselle tehtävälle

### Vanhemmille
- ✏️ Helppo tehtävien muokkaus
- 📷 Lisää omia kuvia (PECS) tehtäville
- ⏰ Aseta aikataulut ja kestot
- 🔔 Paikalliset ilmoitukset tehtävien muistutuksiin
- 🔒 PIN-suojaus asetuksille
- 📈 Tilastot päivän edistymisestä
- 🔄 Järjestä tehtäviä uudelleen

## 🚀 Asennus ja käyttö

### Vaatimukset
- Flutter SDK (>=3.0.0)
- Android Studio / Xcode
- Android 5.0+ / iOS 12.0+

### Asennus

1. Kloonaa repositorio:
```bash
git clone https://github.com/yourusername/aamu-rutiini.git
cd aamu-rutiini
```

2. Asenna riippuvuudet:
```bash
flutter pub get
```

3. Luo Hive-generaattorit:
```bash
flutter pub run build_runner build
```

4. Käynnistä sovellus:
```bash
flutter run
```

## 📂 Projektin rakenne

```
lib/
├── main.dart                    # Sovelluksen käynnistys
├── models/                      # Tietomallit
│   ├── morning_task.dart       # Tehtävän tietomalli
│   ├── app_settings.dart       # Asetusten tietomalli
│   └── task_completion.dart    # Suorituksen tietomalli
├── services/                    # Palvelut
│   ├── hive_service.dart       # Tietokannan hallinta
│   ├── notification_service.dart # Ilmoitusten hallinta
│   ├── secure_storage_service.dart # PIN-koodin tallennus
│   └── audio_service.dart      # Ääniefektit
├── providers/                   # Riverpod-tilan hallinta
│   └── app_providers.dart      # Kaikki providerit
├── screens/                     # Näytöt
│   ├── first_launch_screen.dart # Ensimmäisen käynnistyksen näyttö
│   ├── kid/
│   │   └── kid_mode_screen.dart # Lapsitilan päänäyttö
│   └── parent/
│       ├── parent_mode_screen.dart # Vanhempien päänäyttö
│       ├── task_list_screen.dart   # Tehtävälista
│       ├── task_edit_screen.dart   # Tehtävän muokkaus
│       └── settings_screen.dart    # Asetukset
└── widgets/                     # Uudelleenkäytettävät komponentit
    ├── countdown_circle.dart   # Ajastin-widget
    └── task_card_widget.dart   # Tehtäväkortti-widget
```

## 🔧 Konfigurointi

### Android-ilmoitukset

Lisää `android/app/src/main/AndroidManifest.xml` tiedostoon:

```xml
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
```

### iOS-ilmoitukset

Lisää `ios/Runner/Info.plist` tiedostoon:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

## 📖 Käyttöohjeet

### Ensimmäinen käyttökerta

1. Avaa sovellus ensimmäistä kertaa
2. Aseta 4-numeroinen PIN-koodi vanhempien näkymälle
3. Sovellus luo automaattisesti oletusrutiinin

### Lapsitila

- Lapsi näkee listan tehtävistä
- Iso ajastin näyttää ajan lähtöön
- Kun tehtävä on tehty, lapsi painaa "Valmis"-nappia
- Edistymispalkki täyttyy tehtävien edetessä
- Kaikki tehtävät suoritettu → juhla-animaatio! 🎉

### Vanhempien tila

1. Napauta oikeassa ylänurkassa olevaa asetuskuvaketta 5 kertaa
2. Syötä PIN-koodi
3. Muokkaa tehtäviä, aikatauluja ja asetuksia

### Tehtävien muokkaus

1. Avaa vanhempien tila
2. Valitse "Tehtävät"
3. Lisää, muokkaa tai poista tehtäviä
4. Lisää PECS-kuvia kamerasta tai galleriasta
5. Aseta aikataulu ja kesto
6. Järjestä tehtävät uudelleen vetämällä

### Ilmoitusten ajastus

1. Avaa vanhempien tila → Asetukset
2. Varmista että ilmoitukset on päällä
3. Aseta lähtöaika
4. Palaa päävalikkoon
5. Valitse "Ajasta ilmoitukset"

## 🎨 Kuvien lisääminen

### PECS-kuvat

Voit lisätä omia PECS-kuvia tehtäville:

1. Muokkaa tehtävää
2. Napauta kuvakehystä
3. Valitse kuva galleriasta
4. Kuva tallennetaan automaattisesti

### Oletuskuvat

Voit lisätä oletuskuvia `assets/pecs/` kansioon ja viitata niihin:

```
assets/
  pecs/
    nouse.png
    petaa.png
    peseydy.png
    syö.png
    hampaat.png
    lähde.png
```

## 🔔 Ilmoitukset

Sovellus käyttää paikallisia ilmoituksia (flutter_local_notifications):

- Ei vaadi internet-yhteyttä
- Toimii offline-tilassa
- Tarkat ajastetut ilmoitukset
- Mukautettavat äänit ja värinä

## 🔒 Tietoturva

- PIN-koodi tallennetaan turvallisesti (flutter_secure_storage)
- Kaikki data säilytetään laitteella (Hive)
- Ei pilvipalveluja tai tietojen keräämistä
- GDPR-yhteensopiva

## 🐛 Yleisiä ongelmia

### Ilmoitukset eivät toimi

1. Tarkista sovelluksen käyttöoikeudet laitteen asetuksista
2. Varmista että "Älä häiritse" -tila ei ole päällä
3. Android: Salli tarkat hälytykset

### Kuvat eivät lataudu

1. Tarkista tallennustilan käyttöoikeudet
2. Varmista että galleria-oikeudet on myönnetty

### PIN-koodi unohtunut

Poista sovellus ja asenna uudelleen (kaikki data menetetään)

## 🛠️ Kehitystyö

### Build Runner

Kun muokkaat Hive-malleja:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Testaus

```bash
flutter test
```

### Build

Android APK:
```bash
flutter build apk --release
```

iOS IPA:
```bash
flutter build ios --release
```

## 📦 Käytetyt paketit

- **flutter_riverpod**: Tilanhallinta
- **hive** & **hive_flutter**: Paikallinen tietokanta
- **flutter_local_notifications**: Paikalliset ilmoitukset
- **flutter_secure_storage**: Turvallinen tallennus (PIN)
- **image_picker**: Kuvien valinta
- **just_audio**: Ääniefektit
- **uuid**: Uniikkien ID:iden luonti
- **intl**: Päivämäärien käsittely
- **path_provider**: Tiedostopolut

## 📄 Lisenssi

MIT License - vapaa käyttöön ja muokkaukseen

## 🤝 Yhteistyö

Pull requestit ovat tervetulleita! Suurempia muutoksia varten avaa ensin issue keskustelua varten.

## 📞 Tuki

Jos tarvitset apua, ota yhteyttä tai avaa issue GitHubissa.

## 🎯 Tulevat ominaisuudet

- [ ] Useammat teemat ja värivaihtoehdot
- [ ] Puheohjeet (TTS)
- [ ] Viikoittaiset aikataulut
- [ ] Palkintojärjestelmä
- [ ] Tilastot ja raportit
- [ ] Valmis PECS-kuvapankki
- [ ] Viikkonäkymä
- [ ] Moniprofiilit (useampi lapsi)

## 👏 Kiitokset

Kiitos kaikille jotka ovat auttaneet projektin kehityksessä!

---

**Tehty ❤️:llä lapsille ja heidän vanhemmilleen**

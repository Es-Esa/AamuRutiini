# 📦 Julkaisuvalmis APK

## 📍 APK-tiedosto

**Sijainti**: `build/app/outputs/flutter-apk/app-release.apk`  
**Koko**: ~92 MB  
**Versio**: 1.0.0+1  
**Build Type**: Release (tuotanto)

## ✅ Tarkistuslista ennen julkaisua

### Turvallisuus
- [x] Ei API-avaimia tai salaisuuksia lähdekoodissa
- [x] PIN-koodit tallennetaan salattuina (flutter_secure_storage)
- [x] Kaikki data tallennetaan paikallisesti
- [x] .gitignore suojaa arkaluonteiset tiedostot

### Sovelluksen tiedot
- [x] Application ID: `com.example.aamu_rutiini`
- [x] Versio: 1.0.0 (version code: 1)
- [x] Min SDK: 21 (Android 5.0)
- [x] Target SDK: 36 (Android 14+)

### Dokumentaatio
- [x] README.md (projektikuvaus)
- [x] STORE_DESCRIPTION.md (yksityiskohtainen kuvaus)
- [x] GOOGLE_PLAY_DESCRIPTION.md (Play Store -teksti)
- [x] LICENSE (MIT-lisenssi)
- [x] DEVELOPMENT.md (kehitysohjeet)

### Toiminnallisuus
- [x] Lapsitila toimii
- [x] Vanhempien tila (PIN-suojaus)
- [x] PECS-kuvahaku (ARASAAC)
- [x] Äänimuistutukset
- [x] Tehtävien hallinta
- [x] Ajastinlogiikka
- [x] Tutoriaali ensimmäisellä käynnistyskerralla

## 📤 Google Play Store -julkaisu

### Vaadittavat tiedot

**Sovelluksen nimi**:
```
Aamu Rutiini
```

**Lyhyt kuvaus** (80 merkkiä):
```
Aamurutiini-sovellus lapsille PECS-kuvilla ja äänimuistutuksilla
```

**Pitkä kuvaus**: Katso `GOOGLE_PLAY_DESCRIPTION.md`

**Kategoria**: 
- Ensisijainen: Education
- Toissijainen: Parenting

**Kohderyhmä**:
- Perheet
- Lapset (3-12v vanhempien ohjauksella)
- Erityispedagogiikka

**Sisältöluokitus**: PEGI 3 / Everyone

### Kuvat (vaadittavat)

Play Store vaatii seuraavat kuvat:

1. **Sovelluksen kuvake** (512x512 px)
   - PNG-muoto
   - Läpinäkyvä tausta

2. **Feature Graphic** (1024x500 px)
   - Sovelluksen pääbanneri
   - Näkyy Play Storessa

3. **Kuvakaappaukset** (vähintään 2, suositus 4-8)
   - Puhelin: 1080x1920 px tai 1920x1080 px
   - Näytä lapsitila, vanhempien tila, tehtävät, PECS-haku

### Privacy Policy

Sovellus ei kerää käyttäjätietoja, joten yksinkertainen privacy policy riittää:

```
Aamu Rutiini -sovellus ei kerää, tallenna eikä lähetä mitään käyttäjätietoja. 
Kaikki tiedot tallennetaan vain käyttäjän laitteelle.

Sovellus käyttää ARASAAC-kuvakirjastoa, joka on saatavilla CC BY-NC-SA 4.0 -lisenssillä.
Kuvahaku vaatii internet-yhteyden, mutta sovellus ei lähetä henkilökohtaisia tietoja.
```

## 🔐 Allekirjoitus (Play Store vaatii)

**HUOM**: APK täytyy allekirjoittaa ennen lataamista Play Storeen.

### Luo avainpari (tee tämä kerran)

```bash
keytool -genkey -v -keystore aamu-rutiini-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias aamu-rutiini-key
```

**TÄRKEÄÄ**: 
- Tallenna salasana turvalliseen paikkaan
- Älä lisää .jks-tiedostoa Gittiin
- Lisää `.gitignore`: `*.jks`

### Allekirjoita APK

1. Luo tiedosto `android/key.properties`:
```properties
storePassword=<salasana>
keyPassword=<salasana>
keyAlias=aamu-rutiini-key
storeFile=<polku>/aamu-rutiini-release-key.jks
```

2. Muokkaa `android/app/build.gradle.kts`:
```kotlin
// Lisää before android block:
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // ...existing code...
    
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

3. Buildaa uudelleen:
```bash
flutter build apk --release
```

## 📱 Testaus ennen julkaisua

Testaa APK fyysisellä laitteella:

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

**Tarkista**:
- [ ] Sovellus käynnistyy
- [ ] PIN-koodin asetus toimii
- [ ] Tehtävien lisäys toimii
- [ ] PECS-kuvahaku toimii
- [ ] Äänet soivat
- [ ] Ajastimet toimivat
- [ ] Tutoriaali näkyy ensimmäisellä kerralla

## 🚀 Julkaisuprosessi

1. **Luo Google Play Console -tili**
   - Maksa kertaluonteinen 25 USD -maksu
   - https://play.google.com/console

2. **Luo uusi sovellus**
   - Sovelluksen nimi: "Aamu Rutiini"
   - Oletuskieli: Suomi

3. **Lataa APK** (tai parempi: AAB)
   - Buildaa: `flutter build appbundle --release`
   - Lataa: `build/app/outputs/bundle/release/app-release.aab`

4. **Täytä tiedot**
   - Store listing (kuvaukset, kuvat)
   - Content rating (PEGI 3)
   - Privacy policy
   - Contact details

5. **Julkaise**
   - Internal testing → Closed testing → Production
   - Voi kestää muutamia päiviä

## 📊 Jatkokehitys

- [ ] iOS-tuki (vaatii Apple Developer -tilin, 99 USD/vuosi)
- [ ] App Bundle (AAB) Play Storeen (suositeltu APK:n sijaan)
- [ ] ProGuard/R8 obfuskaatio
- [ ] Crash reporting (Firebase Crashlytics)
- [ ] Analytics (yksityisyyttä kunnioittaen)

## 🆘 Tuki

- **Bugit**: GitHub Issues
- **Keskustelu**: GitHub Discussions
- **Email**: [lisää sähköpostiosoite]

---

**Valmistunut**: {CURRENT_DATE}  
**Build Status**: ✅ Success  
**Ready for**: Play Store Internal Testing

# Aamu Rutiini - Aamurutiini-sovellus lapsille

## 📱 Sovelluksen kuvaus

Aamu Rutiini on avoimen lähdekoodin Flutter-sovellus, joka auttaa lapsia itsenäistymään aamurutiineissa. Sovellus käyttää PECS-kuvia (Picture Exchange Communication System) ja äänimuistutuksia tehtävien visualisointiin ja muistuttamiseen.

### ✨ Pääominaisuudet

- **👶 Lapsitila**: Yksinkertainen käyttöliittymä tehtäväkorteilla
- **👨‍👩‍👧 Vanhempien tila**: PIN-koodilla suojattu hallintapaneeli
- **🖼️ PECS-tuki**: ARASAAC-kuvakirjaston integraatio (20,000+ kuvaa)
- **🔊 Äänimuistutukset**: Mukautettavat äänet tehtäville
- **⏰ Ajastetut hälytykset**: Tehtävien aloitus ja lopetus -äänimerkinnät
- **📅 Päivittäinen nollaus**: Automaattinen edistymisen nollaus joka aamu
- **🔒 Turvallisuus**: PIN-koodilla suojattu vanhempien tila
- **🎨 Mukautettavuus**: Tehtävien keston ja aikataulujen säätö

## 🎯 Käyttötapaukset

Sovellus on suunniteltu erityisesti:
- Lapsille, jotka hyötyvät visuaalisesta tuesta (esim. autismikirjon lapset)
- Perheille, jotka haluavat strukturoida aamurutiinit
- Lapsille, jotka opettelevat aikataulujen noudattamista

## 🔧 Tekninen toteutus

### Käytetyt teknologiat

- **Flutter 3.0+**: Cross-platform-kehitys
- **Riverpod**: State management
- **Hive**: Paikallinen tietokanta
- **flutter_secure_storage**: PIN-koodien turvallinen tallennus
- **just_audio**: Äänitiedostojen toisto
- **ARASAAC API**: PECS-kuvien haku

### Arkkitehtuuri

```
lib/
├── main.dart                 # Sovelluksen aloituspiste
├── models/                   # Datamallit (MorningTask)
├── providers/                # Riverpod-providerit
├── screens/                  # UI-näkymät
│   ├── kid/                 # Lapsitilan näkymät
│   └── parent/              # Vanhempien tilan näkymät
├── services/                 # Bisneslogiikka
│   ├── audio_service.dart   # Äänitoisto
│   ├── timer_service.dart   # Ajastinlogiikka
│   └── task_sound_scheduler.dart  # Äänien ajoitus
└── widgets/                  # Uudelleenkäytettävät komponentit
```

## 🚀 Asennus ja käyttö

### Vaatimukset
- Android 5.0 (API level 21) tai uudempi
- Noin 50 MB tallennustilaa

### Ensimmäinen käyttökerta
1. Asenna APK puhelimeesi
2. Avaa sovellus ja aseta PIN-koodi (4-6 numeroa)
3. Siirry vanhempien tilaan (paina rataskuvaketta)
4. Lisää tehtäviä + -napista
5. Aseta kullekin tehtävälle:
   - Nimi
   - Aloitusaika
   - Kesto
   - PECS-kuva (haku suomeksi tai englanniksi)

### Vanhempien tila
- **PIN-koodi**: Pääsy vanhempien tilaan
- **Tehtävät**: Lisää, muokkaa ja poista tehtäviä
- **Ääniasetukset**: Valitse äänet tehtäville (aloitus, lopetus, muistutus)
- **PECS-kuvahaku**: Etsi kuvia ARASAAC-kirjastosta
- **Lähtöaika**: Aseta aika, jolloin lapsen tulee lähteä

### Lapsitila
- Näyttää yhden tehtävän kerrallaan
- Näytä-nappi näyttää lisätietoja ja PECS-kuvan
- Painamalla tehtävää se merkitään tehdyksi
- Äänimerkinnät muistuttavat tehtävän aloituksesta ja lopetuksesta

## 🔐 Tietosuoja

- **Paikallinen tallennus**: Kaikki tiedot tallennetaan vain laitteelle
- **Ei pilvipalvelua**: Sovellus ei lähetä dataa internetiin
- **PIN-suojaus**: Vanhempien tila suojattu turvallisesti
- **ARASAAC API**: Ainoa ulkoinen yhteys (kuvahaku)

## 📝 Lisenssi

MIT License

Copyright (c) 2025 Aamu Rutiini Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## 🤝 Osallistuminen

Tämä on avoimen lähdekoodin projekti. Osallistuminen on tervetullutta!

### Kehitysehdotuksia

- [ ] iOS-tuki
- [ ] Monipäiväinen aikataulu (viikonpäivät)
- [ ] Palkitsemisjärjestelmä
- [ ] Kustomoidut äänitallenteet
- [ ] Lokalisaatio (englanti, ruotsi)
- [ ] Vanhempien raportointi (tilastot)

## 📧 Yhteystiedot

- **GitHub**: https://github.com/Es-Esa/AamuRutiini
- **Issues**: Ilmoita bugeista tai ehdota ominaisuuksia GitHub Issues -sivulla

## 🙏 Kiitokset

- **ARASAAC**: PECS-kuvat (CC BY-NC-SA 4.0)
- **Flutter-yhteisö**: Erinomaiset kirjastot ja dokumentaatio
- **Käyttäjät ja testaajat**: Palautteesta ja tuesta

---

**Versio**: 1.0.0  
**Viimeisin päivitys**: Marraskuu 2025  
**Platform**: Android 5.0+

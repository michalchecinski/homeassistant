# Home assistant - konfiguracja
[EN](https://github.com/michalchecinski/homeassistant/blob/master/README.md) | [PL](https://github.com/michalchecinski/homeassistant/blob/master/README_PL.md)

[![Build Status](https://github.com/michalchecinski/homeassistant/workflows/Home%20Assistant%20CI/badge.svg)](https://travis-ci.org/michalchecinski/homeassistant)

Oto moja konfiguracja [Home Assistant-a](https://www.home-assistant.io/). Na razie jest raczej prosta, ale ciągle dodaję do niej nowe komponenty i urządzenia.

## Hardware
Home Assistant chodzi u mnie na Raspberry Pi 3B+. Do RPi mam podłączone kilka komponentów:
* 433MHz RF transmiter
* DHT11 sensor temperatury i wilgotności
* Karta dźwiękowa USB

## Software
Poza Home Assistant-em mam kilka serwisów uruchomianych na RPi. Oto one:
* [Home Assistant](https://www.home-assistant.io/)
* [mosquitto](https://mosquitto.org/) (MQTT broker)
* [Mopidy](https://www.mopidy.com/) razem z [Mopidy-Iris](https://github.com/jaedb/Iris) i [Spotify](https://github.com/mopidy/mopidy-spotify)

## Urządzenia
### Outlets / Switches
| Urządzenie      | Ilość | Połączenie   | Opis                                                                                   |
| --------------- | ----- | ------------ | -------------------------------------------------------------------------------------- |
| REV-Ritter L842 | 2     | RF433MHz     | -                                                                                      |
| MQTT Switch     | 1     | Wi-Fi (MQTT) | Przełącznik do kontrolowania wieży stereo. Zbudowany na Wemos D1 mini oraz diodzie IR. |

### Światła
Światła są zarejestrowane jako przełączniki w HA ponieważ steruję nimi za pomocą kodów RF.

| Urządzenie        | Ilość | Połączenie | Opis |
| ----------------- | ----- | ---------- | ---- |
| Pasek LED         | 1     | RF433MHz   | -    |
| Lampka przy łóżku | 1     | RF433MHz   | -    |

### Media
| Urządzenie | Ilość | Połączenie           | Opis                                                |
| ---------- | ----- | -------------------- | --------------------------------------------------- |
| Mopidy     | 1     | Ethernet (localhost) | Klient Mopidy (MPD) zainstalowany razem z HA na RPi |

### Sensory
| Urządzenie         | Ilość | Połączenie  | Opis                                                                                          |
| ------------------ | ----- | ----------- | --------------------------------------------------------------------------------------------- |
| DHT11              | 1     | RPi GPIO    | -                                                                                             |
| Sensor temperatury | 1     | WiFi (MQTT) | Zewnętrzny sensor temperatury zbudowany na Wemos D1 mini. Połączenie po WiFi - protokół MQTT. |

## Sensory programowe
* Air quality WAQI
* OWM (Open Weather Map)
* Czas działania HA
* [Travis](https://travis-ci.org/michalchecinski/homeassistant) - Używam Travisa do automatycznego sprawdzania konfiguracji przed wdrożeniem. Po poprawnym zbudowaniu HA pobiera nową wersję konfiguracji. Takie moje małe CI/CD ;) Komponenty uzywane w tym procesie:
  * [Travis config binary sensor](https://github.com/michalchecinski/homeassistant/blob/master/binary_sensors/travis_cong.yaml)
  * [Pull config automation](https://github.com/michalchecinski/homeassistant/blob/master/automations/maintanance.yaml#L5)
  * [Pull git config shell command](https://github.com/michalchecinski/homeassistant/blob/master/shell_commands.yaml#L1)
  * [Git pull .sh script](https://github.com/michalchecinski/homeassistant/blob/master/bash/git_pull.sh)
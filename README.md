# Home assistant configuration
[![Build Status](https://travis-ci.org/michalchecinski/homeassistant.svg?branch=master)](https://travis-ci.org/michalchecinski/homeassistant)

Here's my [Home Assistant](https://www.home-assistant.io/) configuration. It's rather simple for now, but I constantly add new components and devices to it.

## Hardware
I run Home Assistant on Raspberry Pi 3B+. To RPi I have several components connected:
* 433MHz RF transmitter
* DHT11 temperature and  humidity sensor
* USB Sound Card

## Software
Except Home Assistant I've got also other software services running on RPi:
* [Home Assistant](https://www.home-assistant.io/)
* [mosquitto](https://mosquitto.org/) (MQTT broker)
* [Mopidy](https://www.mopidy.com/) with [Mopidy-Iris](https://github.com/jaedb/Iris) and [Spotify](https://github.com/mopidy/mopidy-spotify) extensions

## Devices
### Outlets / Switches
| Device          | Quantity | Connection | Description                                                                      |
| --------------- | -------- | ---------- | -------------------------------------------------------------------------------- |
| REV-Ritter L842 | 2        | RF433MHz   | -                                                                                |
| MQTT Switch     | 1        | Wi-Fi (MQTT)     | Switch for controlling stereo system. It is build on Wemos D1 mini and IR diode. |

### Lights
Those lights are based on switches in HA configutration, because they are controlled by RF codes.
| Device    | Quantity | Connection | Description |
| --------- | -------- | ---------- | ----------- |
| LED strip | 1        | RF433MHz   | -           |
| Bed lamp  | 1        | RF433MHz   | -           |

### Media
| Device | Quantity | Connection           | Description                                     |
| ------ | -------- | -------------------- | ----------------------------------------------- |
| Mopidy | 1        | Ethernet (localhost) | Mopidy (MPD) client installed on RPi besides HA |

### Sensors
| Device      | Quantity | Connection  | Description                                                                                |
| ----------- | -------- | ----------- | ------------------------------------------------------------------------------------------ |
| DHT11       | 1        | RPi GPIO    | -                                                                                          |
| Temperature | 1        | WiFi (MQTT) | Outside temperature sensor built on Wemos D1 mini. Sending data over WiFi - MQTT protocol. |

## Software sensors
* Air quality WAQI
* OWM (Open Weather Map)
* [Travis](https://travis-ci.org/michalchecinski/homeassistant) - Travis is used in automatic configuration checks. After successful build new version of the config is pulled from git. Components used in this process:
  * [Travis config binary sensor](https://github.com/michalchecinski/homeassistant/blob/master/binary_sensors/travis_cong.yaml)
  * [Pull config automation](https://github.com/michalchecinski/homeassistant/blob/master/automations.yaml#L6)
  * [Pull git config shell command](https://github.com/michalchecinski/homeassistant/blob/master/shell_commands.yaml#L1)
  * [Git pull .sh script](https://github.com/michalchecinski/homeassistant/blob/master/bash/git_pull.sh)
* Uptime
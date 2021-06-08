# Ark Beat
## Contents
<!-- TOC -->

- [Ark Beat](#ark-beat)
  - [Contents](#contents)
  - [What's Ark Beat](#whats-ark-beat)
  - [Ready to go, Doctor?](#ready-to-go-doctor)
  - [Guide on usage](#guide-on-usage)
    - [1. start interface](#1-start-interface)
    - [2. music selection interface](#2-music-selection-interface)
    - [3. game interface](#3-game-interface)
  - [Wanna be creative?](#wanna-be-creative)
    - [Preparations](#preparations)
    - [Work with Skadi](#work-with-skadi)
      - [1. start interface](#1-start-interface-1)
      - [2. record interface](#2-record-interface)
  - [The songs just won't play?](#the-songs-just-wont-play)
  - [Maintainers](#maintainers)
  - [Acknowledgments](#acknowledgments)
  - [License](#license)

<!-- /TOC -->

## What's Ark Beat
***Ark Beat*** is a rhythm game written in masm. It started as a term project of our assembly language class, but now we believe it's a decent game.
> It's also a fan work following ***Muse Dash*** and ***Arknights***
## Ready to go, Doctor?
> For now, only Windows is supported, and tests are carried out on Windows 10 only

If you have put your song(s) in the ***music*** folder, just double click on ***Ark Beat.exe*** and enjoy yourself!
## Guide on usage
The game ***Ark Beat*** has three interfaces: 
+ **start interface**
+ **music selection interface**
+ **game interface**

Let's go through all of them.
### 1. start interface
+ ***Escape*** : **exit** the game
+ ***Any other key*** : start game *(go to **music selection interface**)*
### 2. music selection interface
> Snatch of the current song will be played repeatedly

> Missing cover(s) will be replaced by default cover
+ ***Escape*** : return to ***start interface***
+ ***Space*** : replay the current snatch
  + Should the **snatch** with suffix ***.clip.mp3*** not exist, a *warning* would pop up
+ ***A / Left Arrow*** : switch to previous song
+ ***D / Right Arrow*** : switch to next song
+ ***Return*** : start playing *(go to **game interface**)*
  + Should the **music** with suffix ***.mp3*** **or** ***.wav*** not exist, a *warning* would pop up
  + Should the **notes** with suffix ***.ark1*** **and** ***.ark2*** not exist, a *warning* would pop up
### 3. game interface
+ ***Escape*** : open the ***in-game menu***
  + **In-game menu**
    + ***Escape*** : resume the game
    + ***Enter*** : return to ***music selection interface***
+ ***F / D / S*** : hit the upper track *(Texas beats)*
+ ***J / K / L*** : hit the lower track *(Amiya beats)*
## Wanna be creative?
***Skadi's workshop*** is just for creative Doctors like you!

You could make **notes** for your favourite songs!
### Preparations
The song folder should be as follows:
```
Ark Beat
└─music
    └─foo
        foo.mp3
        foo.clip.mp3    (optional)
        foo.ico         (optional)
        foo.ark1        (to be generated)
        foo.ark2        (to be generated)
```
+ A folder put under the ***music*** folder, with name ***foo*** (it's highly recommended to use the song's name) **of your own choice**
+ A music file named ***foo.mp3*** **or** ***foo.wav*** put under folder ***foo***
  > Normally, an appropriate song's length should be ***90~150s***. But it's not mandatory.
+ *(optional)* A cover file named ***foo.ico*** put under folder ***foo***
+ *(optional)* A snatch file named ***foo.clip.mp3*** put under folder ***foo***
  > Normally, an appropriate snatch's length should be ***15~25s***. But it's not mandatory.

### Work with Skadi
> ***Skadi's workshop*** is a **beatmap maker** for ***Ark Beat***
> 
***Skadi's workshop*** has two interfaces: 
+ **start interface**
+ **record interface**
#### 1. start interface
+ ***Escape*** : **exit** the tool
+ ***W*** : switch to previous song
+ ***S*** : switch to next song
+ ***Space*** : start recording notes *(go to record interface)*
  + Should the **notes** with suffix ***.ark1*** **or** ***.ark2*** do exist, a *warning* regarding whether to overwrite would pop up
  + Should the **music** with suffix ***.mp3*** **or** ***.wav*** not exist, a *warning* would pop up
#### 2. record interface
> There will be a pop up window at the end of record
+ ***Escape*** : return to ***start interface***
+ ***Backspace*** : restart the music to record from scratch
+ ***F / D / S*** : record notes on the upper track
  + The button with **up arrow** reacts
+ ***J / K / L*** : record notes on the lower track
  + The button with **down arrow** reacts

After the record is down, just play it with ***Ark Beat*** to check your own masterpiece!

## The songs just won't play?
Windows' poor **audio decoder** might be the one to blame.
You are ***highly, highly, highly recommended*** to install third-party decoders like [**LAVFilters**](https://github.com/Nevcairiel/LAVFilters/releases).

## Maintainers
+ [@41889732](https://github.com/41889732)
+ [@KiwiXR](https://github.com/KiwiXR)
+ [@SuMuYou](https://github.com/SuMuyou)
+ [@yinkejia](https://github.com/yinkejia)

## Acknowledgments
We refer to these games as we are big fans of them.
+ [**Muse Dash**](http://www.peroperogames.com/)
+ [**Arknights**](https://ak.hypergryph.com/)

## License
[MIT](https://github.com/107dot25/Ark-Beat/blob/main/LICENSE) © [107dot25](https://github.com/107dot25)
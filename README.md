# GTA Radio Player
A script that sends hotkeys for the purpose of controlling an external media player as if it were in-game GTA radio. Contributions by Anti and hoxi.

Inspired as an expanded version of S's [GTA Radio External](https://github.com/lotsofs/GTA-Radio-External).
Currently only supports GTA III, Vice City (all international releases plus Vice City Japanese) and San Andreas (1.0/1.01 (EU/US), Steam 3.0 and NewSteam R2). I imagine this can be done to support other GTA games as well. Report issues here in GitHub or by @ing me where I can be @ed. (Twitter @srlMhmd, Discord Mhmd_FVC#8760)

## Download
[v2](https://github.com/MhmdFVC/GTARadioPlayer/releases/download/v2/GTARadioPlayer-v2.zip) 2021/11/23

## Getting Started
**(! This program currently won't work properly on players without versatile global hotkey support !)** (sorry)

Extract the zip file somewhere. I'd recommend you make a shortcut, because those WAV files and config file aren't going to be nice to go through each time. After that, just launch the program and follow the steps outlined in the ? dialog by the keybinds, and check START when you're ready to go. Further reading is below.

## Rundown
Basically, it reads memory values off of certain addresses that can be used to determine whether music should be playing, paused, muted, or unmuted.
It mutes when on foot, in certain buildings, when the menu is open, or when a mission is passed (need to find workaround for mission pass). It pauses while playing a replay. In vehicles and the sound config menu, music will play. **This does not work with GTA III's ambulance, firetruck, Mr. Whoopee, or other vehicles with no radio/chatter, unfortunately.**

### Note on keybinds
**Keybinds for Mute/Pause should not use modifier keys that are also bound in-game**, since this will also send the modifier key to the game, possibly interfering with gameplay.

On a similar note, one major limitation of the program at the moment is that because it sends hotkeys without releasing modifier keys (as to not interfere with gameplay), **you must bind multiple keys in your media player for every combination of modifier keys that you might use in-game**. For example, if you sprint with Shift and hold sub-missions with Alt, and your base Mute hotkey is F10, you'll want to bind F10, Shift+F10, Alt+F10, and potentially Shift+Alt+F10 as global hotkeys in your media player. If you don't do this, your media player will fail to register F10 as mute is you're holding Shift when entering a vehicle for example, since the actual key sent is Shift+F10.

**Unfortunately, this means that if you're using a player that does not have versatile hotkey support (Spotify, WMP, etc.), this isn't going to work for you.** I'm too much of a noob to properly figure out how to send keypresses directly to specific windows, but maybe someone will come along and do the honors.

## HTTP Request muting/pausing
*Currently, only foobar2000, Winamp and Spotify are supported with this method.*

This method uses [beefweb](https://www.foobar2000.org/components/view/foo_beefweb) for foobar2000 and [httpQ](http://httpq.sourceforge.net/) for Winamp to control the player using HTTP requests. This eliminates the need to use standard keybinds. However, due to httpQ's limitation, all actions performed on Winamp have a 1-2 second delay. I don't think much can be done about that, other than switching the plugin used to control Winamp. If you know of a good plugin for Winamp that supports controlling the player using external code, let me know (hoxi#9571 on Discord).

### Spotify support
Spotify support is made possible by the [Spotify.ahk](https://github.com/CloakerSmoker/Spotify.ahk) library. Due to limitations imposed by Spotify, the program only works with Premium accounts.

## Mission Passed theme
If you check this option, the program will play miscom3.wav or miscomVC.wav upon mission completion, depending on your game. You can use the III and VC buttons to test the volume levels and adjust them in the volume mixer, which you're probably going to want to do. In (most) situations where the theme gets interrupted, yeah.wav (a blank sound file) is played in order to interrupt playback. I know, it's kind of ghetto, but AHK didn't seem to have another way of doing this. This feature would be unnecessary for San Andreas since it plays the theme regardless of the music being on or off.

## On/Off
This lets you configure a keybind that completely disables functionality while the program is started (you'll need to restart the program once you've bound a new key). I made this as a workaround for weird issues when trying to stop playback during Trial by Dirt duping in Vice City 100% speedruns, but you may find it useful in other situations as well. It only changes state when your game is open.

## Config file
Upon changing any settings, a config.ini file will be created to store your settings. If you bind any "strange" keys (F13-24 using AHK, Media_Play_Pause, etc.), they will not appear properly in the program, but they will still work. They also appear properly in the config file, so you can check them there if necessary. The Mission Passed theme setting and the state of the program on exit are also stored (e.g., if you close the program while START is checked, it will automatically be ready to go when you launch it the next time).

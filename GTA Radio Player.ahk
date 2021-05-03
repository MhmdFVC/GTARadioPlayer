#SingleInstance,force
SendMode Input
OnExit, GuiClose

; READ CONFIG
IniRead, ToggleMute, config.ini, Keybinds, ToggleMute, %A_Space%
IniRead, TogglePause, config.ini, Keybinds, TogglePause, %A_Space%
IniRead, ToggleDisable, config.ini, Keybinds, ToggleDisable,F20
;IniRead, VolumeUp, config.ini, Keybinds, VolumeUp, %A_Space%
;IniRead, VolumeDown, config.ini, Keybinds, VolumeDown, %A_Space%
IniRead, PlayMissionPassed, config.ini, Behavior, PlayMissionPassed, 1
;IniRead, DialogueAttenuate, config.ini, Behavior, DialogueAttenuate, 0
IniRead, StartProg, config.ini, Behavior, StartProg, 0

ReadMemory(MADDRESS,PROGRAM) ; copied from https://autohotkey.com/board/topic/33888-readmemory-function/
{
	winget, pid, PID, %PROGRAM%

	VarSetCapacity(MVALUE,4,0)
	ProcessHandle := DllCall("OpenProcess", "Int", 24, "Char", 0, "UInt", pid, "UInt")
	DllCall("ReadProcessMemory","UInt",ProcessHandle,"UInt",MADDRESS,"Str",MVALUE,"UInt",4,"UInt *",0)

	Loop 4
	result += *(&MVALUE + A_Index-1) << 8*(A_Index-1)
	return, result
}

; Used for the dialogue stuff which isn't being implemented atm
;int2hex(int)
;{
;	HEX_INT := 8
;	while (HEX_INT--) {
;		n := (int >> (HEX_INT * 4)) & 0xf
;		h .= n > 9 ? chr(0x37 + n) : n
;		if (HEX_INT == 0 && HEX_INT//2 == 0)
;		h .= " "
;	}
;	return "0x" h
;}

; Initialization
MusicAudible = 1 ; start with your player unmuted
PlayerPaused = 0 ; start with player unpaused/playing

gta3 := "ahk_class Grand theft auto 3" ; also used for VC
vc := "GTA: Vice City" ; to distinguish from gta3
sa := "GTA: San Andreas"
game := gta3 ; default (no SA support yet and saves one line of code anyway)
;d1 := ""

RadioAddr := 0x0
ReplayAddr := 0x0
;DialoguePoint := 0x0
;DialogueAddr := 0x0

RadioStatus = 0
ReplayStatus = 0
;DialogueStatus = 0

MissionPassedPlaying = 0
;DialoguePlaying = 0

Disabled = 0
Hotkey, %ToggleDisable%, ToggleDisableProg

; GUI setup
Gui, Add, Text, x5 y5 w120 vVer, Game:
Gui,Add,Text,x180 y5 w20 vOnOff cGreen, ON
GuiControl,Hide,OnOff
Gui, Add, Checkbox, x210 y5 Checked%StartProg% vStartProg gProgram, START
Gui,Add,Button,x225 y162 gAbout, About

;Gui, Add, Checkbox, x5 y30 Checked%DialogueAttenuate% vDialogueAttenuate gUpdate, Lower volume during dialogue (III)
Gui, Add, Checkbox, x5 y50 Checked%PlayMissionPassed% vPlayMissionPassed gUpdate, Play mission passed theme (III/VC)
Gui, Add, Text, x15 y65 vAdjust, * Adjust volume with the volume mixer.
Gui, Add, Button, x205 y55 w30 gMiscom3test, III
Gui, Add, Button, x235 y55 w30 gMiscomVcTest, VC

Gui, Add, Text, x5 y110 vKbc, KEYBIND CONFIG
Gui, Add, Button, x98 y105 gBindHelp vKbch, ?
Gui, Add, Text, x5 y135 vM, Mute*
Gui, Add, Text, x95 y135 vP, Pause
Gui, Add, Text, x5 y165 vTd, On/Off (req. restart)
;Gui, Add, Text, x90 y140 vvu, VolUp
;Gui, Add, Text, x90 y170 vvd, VolDown
Gui, Add, Hotkey, x40 y132 w40 vToggleMute gUpdate, %ToggleMute%
Gui, Add, Hotkey, x130 y132 w40 vTogglePause gUpdate, %TogglePause%
Gui, Add, Hotkey, x100 y162 w110 vToggleDisable gUpdate, %ToggleDisable%
;Gui, Add, Hotkey, x135 y137 w40 vVolumeUp gUpdate, %VolumeUp%
;Gui, Add, Hotkey, x135 y167 w40 vVolumeDown gUpdate, %VolumeDown%

;Gui, Add, Text, x205 y115 vf, F13-24 BINDS
;Gui,Add,Button, x275 y110 gFbindhelp vfh, ?
;Gui,Add,Hotkey, x210 y135 w30 vTempF
;Gui,Add,DropdownList,x245 y135 w50 vFkey, F13|F14|F15|F16|F17|F18|F19|F20|F21|F22|F23|F24
;Gui,Add,Button,x210 y160 w85 gActivateFbind vfbindon, Activate

;GuiControl,Disable,DialogueAttenuate
;GuiControl,Disable,f
;GuiControl,Disable,fh
;GuiControl,Disable,tempf
;GuiControl,Disable,fkey
;GuiControl,Disable,fbindon

Gui,Show,w270 h190,GTA Radio Player v1

if (StartProg)
	gosub Program
	
return

ToggleDisableProg:
	if (Disabled) {
		Disabled = 0
	} else {
		Disabled = 1
	}
	return
About:
	MsgBox,,About, Created by Mhmd_FVC and anti`nInspired as a better version of S's external radio program https://github.com/lotsofs/GTA-Radio-External`nMost memory addresses/values are taken from his program`n`nVersion 1 currently only supports GTA III and VC, but support for other games, expanded media player support, and more fine-tuning features may be to come. Feel free to fork and make your own changes.
	return
Miscom3test:
	SoundPlay, miscom3.wav
	return
MiscomVcTest:
	SoundPlay, miscomVC.wav
	return
Update:
	Gui,Submit,NoHide
	IniWrite, %ToggleMute%, config.ini, Keybinds, ToggleMute
	IniWrite, %TogglePause%, config.ini, Keybinds, TogglePause
	IniWrite, %ToggleDisable%, config.ini, Keybinds, ToggleDisable
	;IniWrite, %VolumeUp%, config.ini, Keybinds, VolumeUp
	;IniWrite, %VolumeDown%, config.ini, Keybinds, VolumeDown
	IniWrite, %PlayMissionPassed%, config.ini, Behavior, PlayMissionPassed
	;IniWrite, %DialogueAttenuate%, config.ini, Behavior, DialogueAttenuate
	IniWrite, %StartProg%, config.ini, Behavior, StartProg
	return
BindHelp:
	MsgBox,,Keybind instructions, 1) Choose keys to bind, and enter them into the boxes below. Make sure your hotkeys don't conflict with any binds in-game or weird stuff will happen.`n`n2) For Mute and Pause, bind them as global hotkeys in your media player. Include duplicates for your most important modifier key binds in-game (e.g. if you make your bind for mute F10, make sure you bind SHIFT+F10, ALT+F10, SHIFT+ALT+F10, etc. in your player) so that your player doesn't misconstrue the bind when holding Shift when entering/exiting a vehicle or when holding sub-mission with Alt, for example.`n`n3) Start with your player UNMUTED and PLAYING. After the initial adjustment (if needed) it should work fine for the rest of your session.`n`n* The reason for using these instead of the media functions you find on keyboards etc. is because they affect system volume, or in the case of play/pause, it makes a huge pop-up about your music show up on Windows 10. Apparently there's a workaround for that though, so if you use that, you can just make your Pause key Media_Play_Pause using your keyboard or manually in the config file.
	return
;fbindhelp:
;	MsgBox,,F13-24 instructions, You can set a temporary keybind to F keys 13-24 to configure your media player and this program to use them. This may be a convenient way to have keys bound without them getting in your way during normal use. The modifier key thing still applies.`n`nIt is not recommended to use this for your mute key, as you will often need to press it manually once per session to get the mute/unmute cycle on track.`n`nUnforunately though, these don't show up properly in the program. If you need to check your special binds, check the config file.
;	return
;activatefbind:
;	Gui,Submit,NoHide
;	if (!fbindon) {
;		fbindon = 1
;		GuiControl,text,fbindon,Deactivate
;		GuiControl,Disable,TempF
;		GuiControl,Disable,Fkey
;		Hotkey, %tempf%, activatefbind2, On
;	} else {
;		fbindon = 0
;		GuiControl,Enable,TempF
;		GuiControl,Enable,Fkey
;		GuiControl,text,fbindon,Activate
;		Hotkey, %tempf%, Off
;	}
;	return
;activatefbind2:
;	Send {Blind}{%fkey%}
;	return
GuiClose:
	if (!MusicAudible)
		Send {Blind}{%ToggleMute%}
		MusicAudible = 1
	if (PlayerPaused)
		Send {Blind}{%TogglePause%}
		PlayerPaused = 0
	ExitApp
	return


Program:
Gui,Submit,NoHide
IniWrite, %StartProg%, config.ini, Behavior, StartProg

GuiControl,Disable,ToggleMute
GuiControl,Disable,TogglePause
GuiControl,Disable,ToggleDisable
;GuiControl,Disable,VolumeUp
;GuiControl,Disable,VolumeDown
GuiControl,Disable,PlayMissionPassed
;GuiControl,Disable,DialogueAttenuate
GuiControl,Disable,Adjust
GuiControl,Disable,Kbc
GuiControl,Disable,P
GuiControl,Disable,M
;GuiControl,Disable,vd
;GuiControl,Disable,vu
GuiControl,Disable,Kbch
GuiControl,Disable,Fh
GuiControl,Disable,Td
Disabled = 0
GuiControl,-c +cGreen,OnOff
GuiControl,Text,OnOff,ON
GuiControl,Show,OnOff

; Actual program
While (StartProg) {
	Gui,Submit,NoHide
	
	sleep 1500 ; so it's not wasting CPU while a game isn't even open
	; determine game version
	if (WinExist(gta3) && !WinExist(vc)) { ; GTA III
		if (ReadMemory(0x5C1E70, gta3) = 1407551829) { ; Retail 1.0
			RadioAddr := 0x8F3967
			ReplayAddr := 0x8F29F0
			GuiControl,Text,Ver,Game: GTA III Retail 1.0
		} else if (ReadMemory(0x5C2130, gta3) = 1407551829) { ; Retail 1.1
			RadioAddr := 0x8F3A1B
			ReplayAddr := 0x8F2AA4
			GuiControl,Text,Ver,Game: GTA III Retail 1.1
		} else if (ReadMemory(0x5C6FD0, gta3) = 1407551829) { ; Steam
			;sleep 3000 ; temporary measure so dialogue address can be properly detected
			RadioAddr := 0x903B5C
			ReplayAddr := 0x902BE4
			;DialoguePoint := 0x22611720
            ;d1 := ReadMemory(DialoguePoint, gta3)
            ;d1 += 1512
            ;DialogueAddr := int2hex(d1)
			GuiControl,Text,Ver,Game: GTA III Steam
		}
	} else if (WinExist(gta3) && WinExist(vc)) { ; Vice City
		if (ReadMemory(0xACD0A2, gta3) = 1793887061) { ; JP (-2FF0/-2FF8)
			RadioAddr := 0x9809D0
			ReplayAddr := 0xA0DB3C
			;ReplayAddr := 0x975DA8
			GuiControl,Text,Ver,Game: Vice City JP
		} else if (ReadMemory(0x667BF0, gta3) = 1407551829) { ; Retail 1.0
			RadioAddr := 0x9839C0
			ReplayAddr := 0x978DA0
			GuiControl,Text,Ver,Game: VC Retail 1.0
		} else if (ReadMemory(0x667C40, gta3) = 1407551829) { ; Retail 1.1 (+8)
			RadioAddr := 0x9839C8
			ReplayAddr := 0x978DA8
			GuiControl,Text,Ver,Game: VC Retail 1.1
		} else if (ReadMemory(0xA402ED, gta3) = 1448235347) { ; Steam (-FF8, +1FF8/+2000 from JP)
			RadioAddr := 0x9829C8
			ReplayAddr := 0x977DA8
			GuiControl,Text,Ver,Game: Vice City Steam
		}
	} ;else if (WinExist(sa)) { ; San Andreas
	;	game := sa
	;	if (ReadMemory(0x82457C, sa) = 38079 || ReadMemory(0x8245BC, sa) = 38079) { ; 1.0 US/EU
	;		RadioAddr := 0x8CB760
	;		GuiControl,Text,Ver,Game: San Andreas Retail 1.0
	;	} else if (ReadMemory(0x8252FC, sa) = 38079 || ReadMemory(0x82533C, sa) = 38079) { ; 1.1 US/EU
	;		RadioAddr := 0x8CCFE8
	;		GuiControl,Text,Ver,Game: San Andreas Retail 1.1
	;	} else if (ReadMemory(0x85EC4A, sa) = 38079) { ; 3.0 Steam
	;		RadioAddr := 0x93AB68
	;		GuiControl,Text,Ver,Game: San Andreas Steam
	;	}
	;}
	else {
		GuiControl,Text,Ver,Game: Undetected
		continue ; doesn't bother with the rest of the script until a game is open
	}
	
	; muting/pausing/etc. loops
	; GTA III
	While (WinExist(gta3) && !WinExist(vc) && StartProg && RadioAddr) {
		RadioStatus := ReadMemory(RadioAddr, gta3)
		ReplayStatus := ReadMemory(ReplayAddr, gta3)
		;DialogueStatus := ReadMemory(DialogueAddr, gta3)
		
		if (RadioStatus = 50629 || RadioStatus = 197) { ; menu
			if (MusicAudible) { ; mute in menu
				Send {Blind}{%ToggleMute%}
				MusicAudible = 0
			} if (MissionPassedPlaying) { ; cancel mission passed theme if game paused
				SoundPlay, yeah.wav
				;SoundPlay, D:\Users\Aiden\Documents\GTA3 User Files\yeah.wav
				MissionPassedPlaying = 0
				sleep 100
			}
		} else if ((RadioStatus = 2827 || RadioStatus = 3084 || RadioStatus = 11 || RadioStatus = 12) || (RadioStatus = 93 || RadioStatus = 116061 || RadioStatus = 453)) { ; mute while on foot/mission passed
			if (MusicAudible) {
				Send {Blind}{%ToggleMute%}
				MusicAudible = 0
			}
			if ((RadioStatus = 93 || RadioStatus = 116061 || RadioStatus = 453) && PlayMissionPassed && !MissionPassedPlaying) { ; mission passed and configured to play theme
				SoundPlay, miscom3.wav
				;SoundPlay, D:\Users\Aiden\Documents\GTA3 User Files\miscom3.wav
				MissionPassedPlaying = 1
			}
		} else if (((RadioStatus >= 0 && RadioStatus <= 10) || RadioStatus = 257 || RadioStatus = 514 || RadioStatus =  771
				|| RadioStatus = 1028 || RadioStatus = 1285 || RadioStatus = 1542 || RadioStatus = 1799 || RadioStatus = 2313
				|| RadioStatus = 2056 || RadioStatus = 2570) && WinExist(gta3) && !MusicAudible) { ; play music in vehicle 
			Send {Blind}{%ToggleMute%}
			MusicAudible = 1
		}
		
		if (ReplayStatus = 0 && WinExist(gta3) && !PlayerPaused) { ; if replay playing and game is open (would assume it's =0 if the game isn't open)
			Send {Blind}{%TogglePause%}
			PlayerPaused = 1
		} else if (ReplayStatus = 19 && PlayerPaused) { ; unpause after replay is over
			Send {Blind}{%TogglePause%}
			PlayerPaused = 0
		}
		;if (DialogueAttenuate) { ; skips if preference not set
		;	if (DialogueStatus = 0 && DialoguePlaying && MusicAudible) { ; attenuate volume when dialogue is playing
		;		;Sleep 1500
		;		DialoguePlaying = 0
		;		Loop 10
		;			Send {Blind}{%VolumeUp%}
		;	} else if (DialogueStatus >= 1 && !DialoguePlaying && MusicAudible) {
		;		DialoguePlaying = 1
		;		Loop 10
		;			Send {Blind}{%VolumeDown%}
		;}
		if (Disabled) {
			GuiControl,-c +cRed,OnOff
			GuiControl,Text,OnOff,OFF
			if (MusicAudible)
				Send {Blind}{%ToggleMute%}
			if (!PlayerPaused)
				Send {Blind}{%TogglePause%}
			While (Disabled && StartProg)
				sleep 100
			if (MusicAudible)
				Send {Blind}{%ToggleMute%}
			if (!PlayerPaused)
				Send {Blind}{%TogglePause%}
			GuiControl,-c +cGreen,OnOff
			GuiControl,Text,OnOff,ON
		}
		
		Gui,Submit,NoHide
		sleep 100
		; RadioStatus values
		; 0-9=normal vehicles, 10=police, 11/12=on foot,  93 = mission passed (1.1), 197=menu, 453 = mission passed (steam)
		; for some reason the retail should-be values have the binary duplicated and tacked on (10 [00001010] -> 2570 [0000101000001010])
	}
	
	; Vice City
	While (WinExist(gta3) && WinExist(vc) && StartProg && RadioAddr) { 
		RadioStatus := ReadMemory(RadioAddr, gta3)
		ReplayStatus := ReadMemory(ReplayAddr, gta3)
		
		if (RadioStatus = 1225) { ; menu or replay
			if (MusicAudible) { ; mute in menu
				Send {Blind}{%ToggleMute%}
				MusicAudible = 0
			}
			if (MissionPassedPlaying) { ; cancel mission passed theme if game paused
				SoundPlay, yeah.wav
				MissionPassedPlaying = 0
			}
		} else if (RadioStatus = 101 && PlayMissionPassed && !MissionPassedPlaying) { ; mission passed stuff
			SoundPlay, miscomVC.wav
			MissionPassedPlaying = 1
		; on foot or in north point mall or riot crowd (on foot) or vercetti mansion (on foot) 
		} else if (RadioStatus != 101 && MissionPassedPlaying) ; reset missionpassedplaying var if it's done playing
			MissionPassedPlaying = 0
		else if ((RadioStatus = 10 || RadioStatus = 11 || RadioStatus = 16 || RadioStatus = 21 || RadioStatus = 22) && MusicAudible) { 
			Send {Blind}{%ToggleMute%}
			MusicAudible = 0
		} else if (((RadioStatus >= 0 && RadioStatus <= 9) || (RadioStatus >= 23 && RadioStatus <= 26)) && WinExist(gta3) && !MusicAudible) { ; play music in vehicle 
			Send {Blind}{%ToggleMute%}
			MusicAudible = 1
		}
		
		if ((ReplayStatus = 1 || ReplayStatus = 65537) && WinExist(gta3) && !PlayerPaused) { ; if replay playing and game is open (would assume it's =0 if the game isn't open)
			Send {Blind}{%TogglePause%}
			PlayerPaused = 1
		} else if ((ReplayStatus = 0 || ReplayStatus = 65536) && PlayerPaused) { ; unpause after replay is over
			Send {Blind}{%TogglePause%}
			PlayerPaused = 0
		}
		
		if (Disabled) {
			GuiControl,-c +cRed,OnOff
			GuiControl,Text,OnOff,OFF
			if (MusicAudible)
				Send {Blind}{%ToggleMute%}
			if (!PlayerPaused)
				Send {Blind}{%TogglePause%}
			While (Disabled && StartProg)
				sleep 100
			if (MusicAudible)
				Send {Blind}{%ToggleMute%}
			if (!PlayerPaused)
				Send {Blind}{%TogglePause%}
			GuiControl,-c +cGreen,OnOff
			GuiControl,Text,OnOff,ON
		}
		
		Gui,Submit,NoHide
		sleep 100
		; RadioStatus values
		; 0-9: various normal vehicles, 10/11: on foot, 19: in ocean view hotel, 21: riot crowd, 23: emergency vehicle
		; 24: post-cabmaggedon kaufman cab, 25/26: hurricane warnings, 70-??: cutscene stuff, 101: mission passed, 1225: menu
	}
	
	; San Andreas
	;While (WinExist(sa) && StartProg) {
	;	RadioStatus := ReadMemory(RadioAddr, sa)
	;	
	;	sleep 100
	;	Gui,Submit,NoHide
	;}
	
	; Mutes/unpauses upon closing the game if it isn't already so it's primed for game restarts
	if (!WinExist(game)) {
		if (!MusicAudible) {
			Send {Blind}{%ToggleMute%}
			MusicAudible = 1
		} else if (PlayerPaused) {
			Send {Blind}{%TogglePause%}
			PlayerPaused = 0
		}
	}
}
GuiControl,Enable,ToggleMute
GuiControl,Enable,TogglePause
GuiControl,Enable,ToggleDisable
;GuiControl,Enable,VolumeUp
;GuiControl,Enable,VolumeDown
GuiControl,Enable,PlayMissionPassed
;GuiControl,Enable,DialogueAttenuate
GuiControl,Enable,Adjust
GuiControl,Enable,Kbc
GuiControl,Enable,P
GuiControl,Enable,M
;GuiControl,Enable,vd
;GuiControl,Enable,vu
GuiControl,Enable,Fh
GuiControl,Enable,Kbch
GuiControl,Enable,Td
GuiControl,Hide,OnOff
GuiControl,Text,Ver,Game:
IniWrite, %StartProg%, config.ini, Behavior, StartProg
if (!MusicAudible) {
	Send {Blind}{%ToggleMute%}
	MusicAudible = 1
}
if (PlayerPaused) {
	Send {Blind}{%TogglePause%}
	PlayerPaused = 0
}
return

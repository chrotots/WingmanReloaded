﻿; PoE Click v1.0.1 : Developed by Bandit
; SwiftClick - Left Click at Coord with no wait between up and down
SwiftClick(x, y){
	Log("SwiftClick: " x ", " y)
	MouseMove, x, y  
	Sleep, 30+(ClickLatency*15)
	Send {Click}
	Sleep, 30+(ClickLatency*15)
	return
}
SpamClick(Toggle:="",Modifier:=""){
	Static Spam := False
	If (Toggle != "") {
		If (Toggle == 1 || Toggle == 0)
			Spam := Toggle
		Else If (Toggle = "True" || Toggle = "true" || Toggle = "on" || Toggle = "On")
			Spam := True
		Else If (Toggle = "False" || Toggle = "false" || Toggle = "off" || Toggle = "Off")
			Spam := False
	} Else
			Spam := !Spam
	If (Modifier != "") {
		Send {%Modifier% Down}
		Sleep, 60+(ClickLatency*15)
	}
	While Spam {
		Send {Click}
		Sleep, 60+(ClickLatency*15)
	}
	If (Modifier != "") {
		Send {%Modifier% Up}
		Sleep, 60+(ClickLatency*15)
	}
}
; LeftClick - Left Click at Coord
LeftClick(x, y){
	Log("LeftClick: " x ", " y)
	BlockInput, MouseMove
	MouseMove, x, y
	Sleep, 60+(ClickLatency*15)
	Send {Click}
	Sleep, 60+(ClickLatency*15)
	BlockInput, MouseMoveOff
	Return
}
; RightClick - Right Click at Coord
RightClick(x, y){
	Log("RightClick: " x ", " y)
	BlockInput, MouseMove
	MouseMove, x, y
	Sleep, 60+(ClickLatency*15)
	Send {Click, Right}
	Sleep, 60+(ClickLatency*15)
	BlockInput, MouseMoveOff
	Return
}
; ShiftClick - Shift Click +Click at Coord
ShiftClick(x, y){
	Log("ShiftClick: " x ", " y)
	BlockInput, MouseMove
	MouseMove, x, y
	Sleep, 60+(ClickLatency*15)
	Send {Shift Down}
	Sleep, 30*Latency
	Send {Click, Down, x, y}
	Sleep, 60+(ClickLatency*15)
	Send {Click, Up, x, y}
	Sleep, 30*Latency
	Send {Shift Up}
	Sleep, 30*Latency
	BlockInput, MouseMoveOff
	return
}
; CtrlClick - Ctrl Click ^Click at Coord
CtrlClick(x, y){
	Log("CtrlClick: " x ", " y)
	BlockInput, MouseMove
	MouseMove, x, y
	Sleep, 30+(ClickLatency*15)
	Send {Ctrl Down}
	Sleep, 45
	Send {Click, Down, x, y}
	Sleep, 60+(ClickLatency*15)
	Send {Click, Up, x, y}
	Sleep, 30
	Send {Ctrl Up}
	Sleep, 30+(ClickLatency*15)
	BlockInput, MouseMoveOff
	return
}
; CtrlShiftClick - Ctrl + Shift Click +^Click at Coord
CtrlShiftClick(x, y){
	Log("CtrlShiftClick: " x ", " y)
	BlockInput, MouseMove
	MouseMove, x, y
	Sleep, 30+(ClickLatency*15)
	Send {Ctrl Down}{Shift Down}
	Sleep, 45
	Send {Click, Down, x, y}
	Sleep, 60+(ClickLatency*15)
	Send {Click, Up, x, y}
	Sleep, 30
	Send {Ctrl Up}{Shift Up}
	Sleep, 30+(ClickLatency*15)
	BlockInput, MouseMoveOff
	return
}
; RandClick - Randomize Click area around middle of cell using lower left Coord
RandClick(x, y){
	Random, Rx, x+10, x+30
	Random, Ry, y-30, y-10
	If DebugMessages
		Log("Randomize: " x ", " y " position to " Rx ", " Ry )
	return {"X": Rx, "Y": Ry}
}
; ClipItem - Capture Clip at Coord
ClipItem(x, y){
  Global RunningToggle
  BlockInput, MouseMove
  Backup := Clipboard
  Clipboard := ""
  Item := ""
  Sleep, 45+(ClipLatency*15)
  MouseMove %x%, %y%
  Sleep, 45+(ClipLatency>0?ClipLatency*15:0)
  Send ^!c
  ClipWait, 0.1
  If ErrorLevel
  {
    Sleep, 15
    Send ^!c
    ClipWait, 0.1
    If ErrorLevel && !RunningToggle
      Clipboard := Backup
  }
  Clip_Contents := Clipboard
  Item := new ItemScan
  BlockInput, MouseMoveOff
  Return
}
; WisdomScroll - Identify Item at Coord
WisdomScroll(x, y){
	Log("WisdomScroll: " x ", " y)
	BlockInput, MouseMove
	RightClick(WisdomScrollX,WisdomScrollY)
	Sleep, 30+Abs(ClickLatency*15)
	LeftClick(x,y)
	Sleep, 45+Abs(ClickLatency*15)
	BlockInput, MouseMoveOff
	return
}

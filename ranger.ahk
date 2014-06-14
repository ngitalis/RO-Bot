;#NoTrayIcon
#Persistent
DetectHiddenWindows, On
CoordMode, Mouse, Relative
CoordMode, Pixel, Relative
;SetDefaultMouseSpeed, 20
;SetMouseDelay, 200


; CONFIG
ro_win := "TrueRO (v2.0)"
this_win := "Ranger"
threshold := 10
resx := 850
resy := 650


; INIT GUI
Gui, Add, Text, x5 y2 w40 h20 vmx
Gui, Add, Text, x45 y2 w40 h20 vmy
Gui, Add, Text, x95 y2 w40 h20 viter
Gui, Add, StatusBar,,
Gui, +AlwaysOnTop
Gui, Show, W150 H70 X100 Y100, Ranger
SB_SetText("Waiting. . .")


; Mouse Monitor
; SetTimer, CheckCoords, 10


; globals
i := 0
is_dead := 0
Random,, NewSeed

    PgUp::
    While ( i < 150 ) {
      activateWin( ro_win )
      SB_SetText("Begin. . . ")
      ; print iter and status
      GuiControl,, iter, %i%

      ; check if disconnected.
      SB_SetText("DC?. . . ")
      is_offline := amIOffline( resx, resy, online_x, online_y )
      ; if disconnected - stop.
      if ( is_offline = 1 ) {
        reload
      }
      
      ; check if dead.
      SB_SetText("Dead?. . . ")
      is_dead := amIDead( resx, resy, dead_x, dead_y )

      ; if dead or first run
      if ( is_dead = 1 || i = 0 ) {
        SB_SetText("Refreshing!. . . ")
        is_dead := 0

        ; go to town
        chatting := amIChatting( resx, resy, ok_x, ok_y )
        if ( chatting = 0 )
          Send {Enter}
        Sleep 500
        Send @go 7
        Sleep 200
        Send {Enter}
        randomSleep(4000, 7000)
        Send {Enter}

        ; in town, heal
        MouseMove 313, 263 ; healer.
        randomSleep(500, 700)
        Click
        randomSleep(500, 700)
        btn_exists := findOkBtn( resx, resy, ok_x, ok_y )
        if (btn_exists = 1) {
          Send {Enter}
        }
        randomSleep(200, 300)

        ; in town, buff
        Send {F4} ; truesight
        randomSleep(500, 700)
        Send {F3} ; concentrate
        randomSleep(200, 300)

        ; use warper
        MouseMove 469, 258 ; warper.
        randomSleep(500, 700)
        Click
        randomSleep(200, 300)
        Send {Enter}
        randomSleep(4000, 7000)

        ; initial warp
        Send {F5}
      }

      SB_SetText("Killing Shit. . . ")
      ; start attack loop
      theta := 0
      x_ctr := 400
      y_ctr := 300
      step := 30
      radius := 20

      while ( radius < 180 ) {
        T := theta * 0.01745329252
        x := x_ctr + radius*Cos(T)
        y := y_ctr + radius*Sin(T)


        is_dead := amIDead( resx, resy, dead_x, dead_y )
        if ( is_dead = 1 )
          Break

        MouseMove, %x%, %y%
        Send {F1} ; arrow storm
        Click


        theta := theta + step
        radius := radius + 5
      }

      Sleep 1000

      ; teleport
      Send {F5}
      
      i++
    }
    SoundPlay *16
    return

    PgDn::
    reload
    return

amIOffline(resx, resy, byref online_x, byref online_y) {
    ImageSearch, foundX, foundY, 0, 0, resx, resy, ranger/dc_txt.png
    online_x := foundX
    online_y := foundY
    if ErrorLevel = 1
        return 0
    else if ErrorLevel = 0
        return 1
}

amIDead(resx, resy, byref dead_x, byref dead_y) {
    ImageSearch, foundX, foundY, 0, 0, resx, resy, ranger/dead2.png
    dead_x := foundX
    dead_y := foundY
    if ErrorLevel = 1
        return 0
    else if ErrorLevel = 0
        return 1
}

amIChatting(resx, resy, byref chat_x, byref chat_y) {
    ImageSearch, foundX, foundY, 0, 0, resx, resy, ranger/chatbox_w.png
    chat_x := foundX
    chat_y := foundY
    if ErrorLevel = 1
        return 0
    else if ErrorLevel = 0
        return 1
}

findOkBtn(resx, resy, byref ok_x, byref ok_y) {
    ImageSearch, foundX, foundY, 0, 0, resx, resy, ranger/ok.png
    ok_x := foundX
    ok_y := foundY
    if ErrorLevel = 1
        return 0
    else if ErrorLevel = 0
        return 1
}

randomSleep(low, high) {
  Random, randVar, low, high
  Sleep randVar
}

activateWin( win ) {
    WinActivate %win%
    WinWaitActive %win%, , 5
}

activateWinID( win_id ) {
    WinActivate ahk_id %win_id%
    WinWaitActive ahk_id %win_id%, , 5
    if ErrorLevel = 1
        activateWin( this_win )
}

; mouse checker routine
CheckCoords:
    MouseGetPos, X, Y
    GuiControl,, mx, %X%
    GuiControl,, my, %Y%
    return

; destructor
GuiClose:
    ExitApp
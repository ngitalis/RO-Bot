; #NoTrayIcon
#Persistent
DetectHiddenWindows, On
CoordMode, Mouse, Relative
CoordMode, Pixel, Relative
Random,, NewSeed


; INIT GUI
Gui, Add, Text, x5 y2 w40 h20 vmx
Gui, Add, Text, x45 y2 w40 h20 vmy
Gui, Add, Text, x95 y2 w40 h20 viter
Gui, Add, StatusBar,,
Gui, +AlwaysOnTop
Gui, Show, W150 H70 X100 Y100, Ranger
SB_SetText("Idle. . .")

ro_win := "TrueRO (v2.0)"
this_win := "Ranger"


Class State {
  ; state list ENUM for main switch
  static TOWN := "Town"
  static HEAL := "Heal"
  static BUFF := "Buff"
  static WARP := "Warp"
  static ATTACK := "Attack"
}


; doesnt work.
; i think AHK is too limiting to do this.
Class Keys {
  __New(arrow_storm, truesight, concentrate, flywing) {
    this.arrow_storm := arrow_storm
    this.truesight := truesight
    this.concentrate := concentrate
    this.flywing := flywing
  }
}


Class Spirograph {
  theta := 0

  __New(resx, resy, radius=20, radius_step=5, theta_step=30) {
    this.resx := resx
    this.resy := resy
    this.x_ctr := (resx-50)/2
    this.y_ctr := (resy-50)/2

    this.max_radius := max_radius 
    this.d_radius := radius 
    this.radius := radius 
    this.radius_step := radius_step 
    this.theta_step := theta_step 
  }

  step( ) {
      T := this.theta * 0.01745329252
      x := this.x_ctr + this.radius*Cos(T)
      y := this.y_ctr + this.radius*Sin(T)
      this.theta := this.theta + this.theta_step
      this.radius := this.radius + 5

      MouseMove, %x%, %y%

      return this.radius
  }

  reset( ) {
    this.radius := this.d_radius
  }
}


; arrow_storm := F1
; truesight := F2
; concentrate := F3
; flywing := F4
Class Ranger {
  state := State.TOWN
  teleports := 0
  healer_x := 0
  healer_y := 0
  warper_x := 0
  warper_y := 0
  hp := 0
  sp := 0

  __New(my_window, max_teleports=200, attack_interval=180, home_location=7, arrow_storm=false, truesight=false, concentrate=false, flywing=false) {
    this.max_teleports := max_teleports
    this.home_location := home_location
    this.attack_interval := attack_interval

    ; bypass object limits. . .
    ; if ( !arrow_storm )
    ;   arrow_storm := F1
    ; if ( !truesight )
    ;   truesight := F2
    ; if ( !concentrate )
    ;   concentrate := F3
    ; if ( !flywing )
    ;   flywing := F4

    ; this.keys := new Keys(arrow_storm, truesight, concentrate, flywing)
    
    this.window := my_window
    WinGetPos, , , resx, resy, %my_window%
    this.resx := resx
    this.resy := resy

    this.spirograph := new Spirograph(resx, resy)
  }

  town( ) {
    ; check chatbox
    ; open chatbox
    while ( !this.amIChatting( ) ) {
      Send {Enter}
      Sleep 200
    }
    ; send @go home 
    home_location := this.home_location
    Send @go %home_location%
    randomSleep(200, 400)
    Send {Enter}

    ; TODO: wait until warped - return true : else return false.
    ; how to detect if warp is done? - pixelsearch for 3 changes?
    ; temp:
    randomSleep(4000, 7000)
    Send {Enter}
    return true
  }

  heal( ) {
    ; TODO: check if character can move by accident.
    ; move mouse to x / y
    ; if healer text not found - find healer.
    ; if healer text is found, click healer
    ; if : ok button found hit enter : else ret false
    ; wait until HP == 100 and ret true?

    ; temp 
    ; TODO: REFACTOR
    MouseMove 313, 263 ; healer.
    randomSleep(500, 700)
    Click

    ; wait for ok.
    while ( !this.isThereAnOKButton( ) ) { ; or if HP is full. . .

    }
    randomSleep(200, 400)
    Send {Enter}
    randomSleep(200, 400)
    return true

    ; if hp is not full return false.
  }

  buff( ) { ; can probably tighten this.
    Send {F2}
    randomSleep(500, 2000)
    Send {F3}
    randomSleep(500, 2000)
    return true
  }

  warp( ) {
    ; move mouse to x / y
    ; if warper text not found - find warper.
    ; if warper text is found, click warper
    ; if : ok button is found hit enter : else ret false
    ; wait until warped and ret true

    ; temp.
    ; TODO: REFACTOR
    MouseMove 469, 258 ; warper.
    randomSleep(500, 700)
    Click

    ; wait for ok. ; must time out. . . 
    while ( !this.isThereAnOKButton( ) ) {

    }
    randomSleep(200, 400)
    Send {Enter}

    ; TODO: wait until warped - return true : else return false.
    ; how to detect if warp is done? - pixelsearch for 3 changes?
    ; temp:
    randomSleep(4000, 7000) ; wait for warp - should do pixel check
    return true
  }

  attack( ) {
    ; if dead or out of sp : return false
    is_dead := this.amIDead( )
    if ( is_dead = 1 )
      return false
    ; TODO: check if out of sp. and DC?

    ; until at max radius spin mouse then arrow storm
    while ( this.spirograph.radius < this.attack_interval ) {
      this.spirograph.step( )
      Send {F1}
      Click
    }

    this.spirograph.reset( )

    ; if done : return true
    randomSleep(200, 400)
    return true
  }

  flyfly( ) {
    Send {F4}
    this.teleports++
  }

  amIDead( ) {
    ImageSearch, foundX, foundY, 0, 0, this.resx, this.resy, ranger/dead2.png
    if ErrorLevel = 1
        return 0
    else if ErrorLevel = 0
        return 1
  }

  amIOffline( ) {
    ImageSearch, foundX, foundY, 0, 0, this.resx, this.resy, ranger/dc_txt.png
    if ErrorLevel = 1
        return 0
    else if ErrorLevel = 0
        return 1
  }

  amIChatting( ) {
    ImageSearch, foundX, foundY, 0, 0, this.resx, this.resy, ranger/chatbox_w.png
    if ErrorLevel = 1
        return 0
    else if ErrorLevel = 0
        return 1
  }

  isThereAnOKButton( ) {
    ImageSearch, foundX, foundY, 0, 0, this.resx, this.resy, ranger/ok.png
    if ErrorLevel = 1
        return 0
    else if ErrorLevel = 0
        return 1
  }

  whatsMyHP( ) {
    ; hp location is hardcoded into game
    ; border: 0x10189C
    ; hp: 0x10EF21
    ; grey: 0x424242
    ; can use hp bar border mask for init location.
  }

  whatsMySP( ) {
    ; sp location is hardcoded into game
    ; border: 0x10189C
    ; blue: 0x1863DE
    ; grey: 0x424242
  }

  findHealer( ) {

  }

  findWarper( ) {

  }

  beep( ) {
    SoundPlay *16
  }

  get(var) {
    return var
  }
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



    ; main
    PgUp::
      activateWin( ro_win )
      ranger := new Ranger( ro_win )
      ; control ranger.
      While ( ranger.teleports < ranger.max_teleports ) {
        SB_SetText(ranger.state)
        teleports := ranger.teleports
        GuiControl,, iter, %teleports%

        ; offline check
        is_offline := ranger.amIOffline( )
        if ( is_offline = 1 ) {
          ranger.beep( )
          break
        }

        if ( ranger.state = State.TOWN ) {
          if ( ranger.town( ) )
            ranger.state := State.HEAL
        }

        else if ( ranger.state = State.HEAL ) {
          if ( ranger.heal( ) )
            ranger.state := State.BUFF
        }

        else if ( ranger.state = State.BUFF ) {
          if ( ranger.buff( ) )
            ranger.state := State.WARP
        }

        else if ( ranger.state = State.WARP ) {
          if ( ranger.warp( ) ) {
            ranger.flyfly( )
            ranger.state := State.ATTACK
          }
        }

        else if ( ranger.state = State.ATTACK ) {
          if ( ranger.attack( ) )
            ranger.flyfly( )
          else 
            ranger.state := State.TOWN
        }
      }

      ranger.beep( )
      return

    PgDn::
      reload
      return

    Insert::
      ; tests
      ranger := new Ranger( ro_win )
      ranger.heal( )
      return



; destructor
GuiClose:
    ExitApp












#NoEnv
#SingleInstance force

SetTitleMatchMode RegEx
DetectHiddenWindows On

If 1 = exit                                   ; Allow command-line to close the script.  Run, %A_AhkPath% "Elite Watchdog.ahk" exit
  ExitApp


CpuCount      := 0
MainProcess   := ""
MainCores     := 0
AltProcesses  := ""
AltCores      := 0

Oculus        :=  [ "OVRServer_x64.exe", "OculusVR.exe", "oculus-overlays.exe" ]


Join(array, sep) {
  for index, elem in array
    str .= elem . sep
  return SubStr(str, 1, -StrLen(sep))
}

GetCpuMask( name ) {
  Process, Exist, %name%
  hPr := DllCall( "OpenProcess", Int, 1536, Int, 0, Int, ErrorLevel )  
  DllCall( "GetProcessAffinityMask", Int, hPr, IntP, ProcessAffinity, IntP, SystemAffinity )
  ; MsgBox GetCpuMask %name% ProcessAffinity %ProcessAffinity% SystemAffinity %SystemAffinity%
  DllCall( "CloseHandle", Int, hPr )
  if(SystemAffinity == 0) {
    MaskOK := 0
    MsgBox Failed to read process info for %name%.  Please make sure the Oculus service and running.  You may need to run this program as Administrator.
  }
  return %SystemAffinity%
}

SetAffinity( name, mask ) {
  Process, Exist, %name%
  if(ErrorLevel > 0) {
    ; MsgBox SetAffinity proc %name% %ErrorLevel%
    hPr := DllCall( "OpenProcess", Int, 1536, Int, 0, Int, ErrorLevel )  
    DllCall( "GetProcessAffinityMask", Int, hPr, IntP, ProcessAffinity, IntP, SystemAffinity )
    ; MsgBox SetAffinity %name% ProcessAffinity %ProcessAffinity% SystemAffinity %SystemAffinity%
    DllCall( "SetProcessAffinityMask", Int, hPr, Int, mask )
    DllCall( "CloseHandle", Int, hPr )
  }
}

SetDefaults(array) {
  global
  CpuCount := 0
  while Mask > 0 {
    CpuCount++
    Mask := Mask >> 1
  }
  ; CpuCount := 8

  if(CpuCount < 4) {
    MsgBox With less than 4 cores, I am not sure what to recommend for you.
    AltCores := 1
    MainCores := 2
  }
  else if(CpuCount >= 8) {
    AltCores := 2
    MainCores := CpuCount - AltCores
  }
  else {
    AltCores := 1
    MainCores := CpuCount - AltCores
  }

  MainProcess := "EliteDangerous64.exe"
  AltProcesses := Join(array, "`n")
}

ShowGUI() {
  global
  Gui, New

  Gui, Add, Text, yp+20, Looks like you have this many cores:
  Gui, Add, Edit, w200 ReadOnly, %CpuCount%

  Gui, Add, Text, yp+50, Wait for this process:
  Gui, Add, Edit, w200 vMainProcess, %MainProcess%
  Gui, Add, Text, , and assign it this many CPU Cores: 
  Gui, Add, Edit, w200 vMainCores, %MainCores%

  Gui, Add, Text, yp+60, Then look for these VR processes:
  Gui, Add, Edit, w200 r4 vAltProcesses, %AltProcesses%
  Gui, Add, Text, , and assign them this many CPU Cores: 
  Gui, Add, Edit, w200 vAltCores, %AltCores%

  Gui, Add, Button, yp+50 gCancel, Cancel/Exit
  Gui, Add, Button, xp+145 yp+0 gStart Default, Ok/Start
  Gui, Add, Text, , 
  Gui, Show,,ED Affinity
}

Cancel() {
  ExitApp
}

Start() {
  global
  Gui, Submit

  X := CpuCount-1
  AltMask := 0
  while(AltCores > 0) {
    AltMask += 2**X
    AltCores--
    X--
  }

  X := 0
  MainMask := 0
  while(MainCores > 0) {
    MainMask += 2**X
    MainCores--
    X++
  }

  Processes := StrSplit(AltProcesses, "`n")

  Loop {
    WinWait ahk_exe %MainProcess%
    for index, proc in Processes {
      if(proc != "") {
        ; MsgBox name %proc% %AltMask%
        SetAffinity( proc, AltMask )
      }
    }
    SetAffinity( MainProcess, MainMask )
    ; MsgBox Remove this after testing
    ; WinWait ahk_exe %MainProcess%
    WinWaitClose ahk_exe %MainProcess%
  }
}


InitialProcess := Oculus[1]
WinWait ahk_exe %InitialProcess%
Mask := GetCpuMask(InitialProcess)

if(Mask > 0) {
  SetDefaults(Oculus)
  if 1 = start
    Start()
  else
    ShowGUI()
}
return

global numInstances := 1
global multiMCLocation := "C:\MultiMC\"
global multiMCNameFormat := "1.16Inst#" ; Edit this to match your instance name formats (CASE SENSITIVE, beware) (the # signifies the instance number)
global resetMacro := "C:\Documents\TheWall\TheWall.ahk"
global launchPrograms := ["C:\Program Files\obs-studio\bin\64bit\obs64.exe", "E:\Documents\Speedrunning\Ninjabrain-Bot-1.2.0.jar", "E:\Documents\Speedrunning\resetTracker-icarus\resetTracker.exe"]
; If you don't want any programs auto launching (why not??) just set the above to []



SetWorkingDir, %A_ScriptDir%

for each, program in launchPrograms {
    SplitPath, program, filename, dir
    isOpen := False
    for proc in ComObjGet("winmgmts:").ExecQuery(Format("Select * from Win32_Process where CommandLine like ""%{1}%""", filename)) {
        isOpen := True
        break
    } 
    if (!isOpen)
        Run, %filename%, %dir%
}

if (FileExist(multiMCLocation . "MultiMC.exe")) {
    Loop, %numInstances% {
        instName := StrReplace(multiMCNameFormat, "#", A_Index)
        instDir := multiMCLocation . "\instances\" . instName
        if (!IsInstanceOpen(instDir)) {
            Run, %multiMCLocation%MultiMC.exe -l "%instName%"
        }
    }
} else {
    Run, "C:\Program Files (x86)\Minecraft Launcher\Minecraft Launcher.exe"
}

checkIdx := 1
while (checkIdx <= numInstances) {
    instName := StrReplace(multiMCNameFormat, "#", checkIdx)
    instDir := multiMCLocation . "instances\" . instName
    if (IsInstanceOpen(instDir)) {
        checkIdx++
    } else {
        Sleep, 200
    }
}

Sleep, 1000
SplitPath, resetMacro, filename, dir
isOpen := False
for proc in ComObjGet("winmgmts:").ExecQuery(Format("Select * from Win32_Process where CommandLine like ""%{1}%""", filename)) {
    isOpen := True
    break
} 
if (!isOpen)
    Run, %filename%, %dir%

IsInstanceOpen(instDir) {
    for proc in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where ExecutablePath like ""%jdk%javaw.exe%""") {
        cmdLine := proc.Commandline
        if(RegExMatch(cmdLine, "-Djava\.library\.path=(?P<Dir>[^\""]+?)(?:\/|\\)natives", thisInst)) {
            thisInstDir := StrReplace(thisInstDir, "/", "\")
            if (instDir == thisInstDir)
                return proc.ProcessId
        }
    }
    return False
}
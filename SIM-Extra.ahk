#Requires AutoHotkey v2.0
#SingleInstance Force
SetWorkingDir A_ScriptDir


; Includes
#Include lib\extra-functions.ahk
#Include lib\github-updater.ahk

dir_path := A_AppData "\" GetAppName()

config_file := dir_path "\config.ini"

icon_path := dir_path "\icon.ico"

icon_url := "https://drive.google.com/uc?export=download&id=1xNRHV5RBpoEbag6-m5r5ry6y8zy1ZMLV"

git_user := "TheBrunoCA"

git_repo := GetAppName()

Class config{
    static auto_update := true
    static hk_shutdown := "^+q" ;Ctrl Shift Q
}

LoadConfigs(&git_hub){
    if(DirExist(dir_path) == ""){
        DirCreate(dir_path)
    }
    if(FileExist(config_file) == ""){
        IniWrite("0", config_file, "version", GetAppName())
        IniWrite(config.auto_update, config_file, "update", "auto-update")
        IniWrite(config.hk_shutdown, config_file, "hotkeys", "hk_shutdown")
    }
    config.auto_update := IniRead(config_file, "update", "auto-update", config.auto_update)
    config.hk_shutdown := IniRead(config_file, "hotkeys", "hk_shutdown", config.hk_shutdown)
    if(!git_hub.is_online){
        return
    }
    if(FileExist(icon_path) == ""){
        Download(icon_url, icon_path)
    }
    TraySetIcon(icon_path)
}

ShutdownPc(){
    answer := MsgBox("Deseja desligar o computador?", , "0x4")
    if(answer == "Yes"){
        sd := MsgBox("Desligando...", ,"T5 Cancel")
        if(sd == "Timeout"){
            ProcessClose "GoogleDriveFS.exe"
            Shutdown 5
        }
    }
}

github := Git(git_user, git_repo)

LoadConfigs(&github)

if(config.auto_update){
    CheckUpdates(&github, config_file)
}

^+q::ShutdownPc()
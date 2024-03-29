﻿#SingleInstance Force
#Requires AutoHotkey v2.0

#Include ..\libraries\Bruno-Functions\ImportAllList.ahk
#Include ..\libraries\Github-Updater.ahk\github-updater.ahk


debug := false
if debug
    MsgBox("Debug is active")

username := "TheBrunoCA"
repository := "SIM-Extra"
buscaPMCRepo := "BuscaPMC"
buscaPMCPath := A_AppData "\" username "\" buscaPMCRepo
buscaPMCConfig := buscaPMCPath "\" buscaPMCRepo "_config.ini"
icon_url := "https://drive.google.com/uc?export=download&id=19RKBTniHoFkcezIGyH1SoClP5Zz4ADu0"
app_name := GetAppName()
extension := GetExtension()
hard_version := "0.154"
install_path := A_AppDataCommon "\" username "\" repository
buscaPMCPath := install_path "\" buscaPMCRepo ".exe"
install_full_path := install_path "\" A_ScriptName
auto_start_path := A_StartupCommon "\" repository ".lnk"
install_bat := A_Temp "\install_bat.bat"
icon_id := StrSplit(icon_url, "id=")[2]
icon_path := install_path "\" icon_id ".ico"
icon_changed := FileExist(icon_path) == ""
is_installed := debug ? true : A_ScriptDir == install_path
was_installed := FileExist(install_bat) != ""
simConfigIniPath := "C:\SIM\config.ini"
config := Configuration(install_path)
was_updated := config.ini["info", "version"] < hard_version
retroceded := config.ini["info", "version"] > hard_version

SetIcon()

if !is_installed
    InstallApp()

github := Git(username, repository)
buscaGithub := Git(username, buscaPMCRepo)
update_available := hard_version < github.GetVersion()

SetTimer(CheckUpdates, 60000)

CheckUpdates() {
    github.Reload()
    try{
        global update_available := hard_version < github.GetVersion()
    }
}

if config.auto_update and update_available
    UpdateApp()


if was_updated {
    config.ini["info", "version"] := hard_version
    config.Reload(install_path)
}

if retroceded {
    config.ini["info", "version"] := hard_version
    config.Reload(install_path)
}

hotkeys := HotkeysConfig(install_path)

if was_installed {
    MsgBox("Instalado com sucesso.`nPressione " hotkeys.shutdown " para abrir o menu.")
    try {
        FileDelete(install_bat)
    }
    catch Error as e {
        if FileExist(install_bat) {
            if !A_IsAdmin { ;TODO: In all instances of asking for this, catch the exception if denied and send a msgbox.
                MsgBox("Ocorreu um problema na instalação, o aplicativo será reiniciado para corrigir.")
                if A_IsCompiled
                    Run '*RunAs "' A_ScriptFullPath '" /restart'
                else
                    Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
            }
            else {
                bat := BatWrite(A_Temp "\1.bat")
                bat.DeleteFile(install_bat)

                Run bat.path, , "Hide"
            }
        }
    }
}

Class Configuration extends DynamicClass {

    __Load(dir_path) {
        this.dir_path := NewDir(dir_path)
        this.ini := Ini(dir_path "\config.ini")
        this.ini_version := this.ini["info", "version", hard_version]
        this.auto_update := this.ini["update", "auto_update", true]
        this.auto_start := this.ini["config", "auto_start", true]
        SetAutoStart(this.auto_start)
    }
}

Class HotkeysConfig extends DynamicClass {
    __Load(dir_path) {
        this.dir_path               := NewDir(dir_path)
        this.ini                    := Ini(dir_path "\hotkeys.ini")
        this.shutdown               := this.ini["hotkeys", "shutdown", "^+q"]
        this.open_menu              := this.ini["hotkeys", "open_menu", "^+m"]
        this.open_BuscaPMC          := this.ini["hotkeys", "open_BuscaPMC", "^+a"]
        this.default_user_hk        := this.ini["hotkeys", "default_user_hk", "bb"]
        this.default_user_string    := this.ini["hotkeys", "default_user_string", "balcao b"]
        this.Enable()               
    }

    Disable() {
        Hotkey(this.shutdown, "off")
        Hotkey(this.open_menu, "off")
        Hotkey(this.open_BuscaPMC, "off")
        Hotstring(":*:" this.default_user_hk, "off")
    }

    Enable() {
        Hotkey(this.shutdown, ShutdownPc, "on")
        Hotkey(this.open_menu, OpenMenu, "on")
        Hotkey(this.open_BuscaPMC, openBuscaPMC, "on")
        Hotstring(":*:" this.default_user_hk, LoginDefaultUser, "on")
    }

    __BeforeReload() {
        this.Disable()
    }

}

LoginDefaultUser(ThisHotstring) {
    windowLogin := "SIM - login"
    windowAuth := "F_AUT"
    store := IniRead(simConfigIniPath, "Connection", "LOJASSINCRONIZA", "638,248")
    store := StrSplit(store, ",")
    store := IniRead(simConfigIniPath, "MultiSuporte", "CNPJ", "06.031.296/0001-94") == "06.031.296/0001-94" ? store[2] : store[1]

    if WinExist(windowLogin) {
        WinActivate(windowLogin)
        ControlFocus("TEdit3", windowLogin)
        ControlSetText(store, "TEdit3", windowLogin)
        ControlSetText(StrSplit(hotkeys.default_user_string, " ")[1], "TEdit2", windowLogin)
        ControlSetText(StrSplit(hotkeys.default_user_string, " ")[2], "TEdit1", windowLogin)
        ControlFocus("TButton2", windowLogin)
        ControlClick("TButton2", windowLogin, , "LEFT")
        Send("{Enter}")
    }
    else if WinExist(windowAuth){
        WinActivate(windowAuth)
        ControlSetText(StrSplit(hotkeys.default_user_string, " ")[1], "TEdit2", windowAuth)
        ControlSetText(StrSplit(hotkeys.default_user_string, " ")[2], "TEdit3", windowAuth)
        ControlFocus("TButton3", windowAuth)
        ControlSend("{Enter}", "TButton3", windowAuth)
        ControlClick("TButton3", windowAuth, , "LEFT")
    }
}

ShutdownPc(ThisHotkey) {
    asw := MsgBox("Deseja desligar o pc?", "Desligarás?", "0x4 0x1000 0x20")
    if asw == "Yes"
        Shutdown(13)
}

OpenMenu(ThisHotkey) {
    if update_available and config.auto_update {
        MsgBox("Atualização encontrada, reinicie o aplicativo para atualizar.")
    }
    MainGui.Show()
}

SetIcon() {
    if icon_changed {
        if IsOnline() {
            try {
                Download(icon_url, icon_path)
                TraySetIcon(icon_path)
                return
            }
        }
        try {
            TraySetIcon("*")
        }
        return
    }
    try {
        TraySetIcon(icon_path)
    }
}

InstallApp() {
    if !A_IsAdmin { ;TODO: In all instances of asking for this, catch the exception if denied and send a msgbox.
        MsgBox("Para ser instalado, o aplicativo precisa de privilégios de administrador.")
        try{
            if A_IsCompiled
                Run '*RunAs "' A_ScriptFullPath '" /restart'
            else
                Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
        }
    }
    FileCreateShortcut(install_full_path, A_Desktop "\" repository ".lnk", , , , A_IconFile)
    bat := BatWrite(install_bat)

    bat.TimeOut(1)
    bat.MoveFile(A_ScriptFullPath, install_path)
    bat.Start(install_full_path)

    MsgBox("O aplicativo será instalado agora, apenas aguarde.")
    Run bat.path, , "Hide"
    ExitApp(200)
}

UpdateApp(arg*) {
    a := MsgBox("O aplicativo será atualizado.`nApenas aguarde.", repository, "t3")

    github.DownloadLatest(A_Temp, repository)
    bat := BatWrite(A_Temp "\update_bat.bat")
    bat.TimeOut(1)
    bat.MoveFile(install_full_path, install_path "\" repository "_old" github.GetExtension())
    bat.MoveFile(A_Temp "\" repository github.GetExtension(), install_full_path)
    bat.Start(install_full_path)

    Run bat.path, , "Hide"
    ExitApp(100)

}

SetAutoStart(set_value) {
    if !set_value and !FileExist(auto_start_path)
        return

    if set_value and FileExist(auto_start_path)
        return

    if !A_IsAdmin { ;TODO: In all instances of asking for this, catch the exception if denied and send a msgbox.
        if A_IsCompiled
            Run '*RunAs "' A_ScriptFullPath '" /restart'
        else
            Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
    }
    if !set_value {
        FileDelete(auto_start_path)
        return
    }
    FileCreateShortcut(install_full_path, auto_start_path, , , , A_IconFile)
}

MainGui := Gui("-MaximizeBox -MinimizeBox -Resize +OwnDialogs", repository " v-" hard_version)
MainGui.SetFont("s20")
MainGui.AddText("", repository " por " username)
MainGui.SetFont("s8")
tabs_main := MainGui.AddTab(, ["Geral", "Atalhos", "Janelas para fechar", "Configurações"])
tabs_main.UseTab(1)
MainGui.AddText(, "Login do usuário padrão")
MainGui.AddEdit("vedit_default_user_username").Value := StrSplit(hotkeys.default_user_string, " ")[1]
MainGui.AddEdit("vedit_default_user_password").Value := StrSplit(hotkeys.default_user_string, " ")[2]
btn_open_BuscaPMC := MainGui.AddButton("vbtn_open_BuscaPMC", "Buscar medicamento.")
btn_open_BuscaPMC.OnEvent("Click", openBuscaPMC)
tabs_main.UseTab(2)
MainGui.AddText(, "Atalho para desligar pc")
MainGui.AddHotkey("vhk_shutdown").Value := hotkeys.shutdown
MainGui.AddText(, "Atalho para abrir menu")
MainGui.AddHotkey("vhk_open_menu").Value := hotkeys.open_menu
MainGui.AddText(, "Atalho para o BuscaPMC")
MainGui.AddHotkey("vhk_open_BuscaPMC").Value := hotkeys.open_BuscaPMC
MainGui.AddText(, "Atalho para usuário padrão")
MainGui.AddEdit("vedit_default_user_hotkey").Value := hotkeys.default_user_hk

tabs_main.UseTab(3)
config.ini["windows_to_close", "windows"] .= ",;,,;,"
config.ini["windows_to_close", "windows"] := StrReplace(config.ini["windows_to_close", "windows"], ",;,,;,,;,", "")
config.ini["windows_to_close", "windows"] := StrReplace(config.ini["windows_to_close", "windows"], ",;,,;,", "")
MainGui.AddEdit("vedit_windows_to_close w250 h200").Value :=StrReplace(config.ini["windows_to_close", "windows"], ",;,", "`n")

tabs_main.UseTab(4)
MainGui.AddCheckbox("vckb_auto_update", "Atualizar automaticamente").Value := config.auto_update
MainGui.AddCheckbox("vckb_auto_start", "Abrir ao iniciar").Value := config.auto_start

tabs_main.UseTab()
btn_submit := MainGui.AddButton("xs", "Aplicar")
btn_submit.OnEvent("Click", MainGuiSubmit)

MainGuiSubmit(arg*) {
    opts := MainGui.Submit(true)
    config.ini["update", "auto_update"] := opts.ckb_auto_update
    config.ini["config", "auto_start"] := opts.ckb_auto_start
    opts.edit_windows_to_close .= "`n`n"
    opts.edit_windows_to_close := StrReplace(opts.edit_windows_to_close, "`n`n`n", "")
    opts.edit_windows_to_close := StrReplace(opts.edit_windows_to_close, "`n`n", "")
    winds := StrReplace(opts.edit_windows_to_close, "`n", ",;,")
    config.ini["windows_to_close", "windows"] := winds
    config.Reload(install_path)
    hotkeys.ini["hotkeys", "shutdown"] := opts.hk_shutdown
    hotkeys.ini["hotkeys", "open_menu"] := opts.hk_open_menu
    hotkeys.ini["hotkeys", "open_BuscaPMC"] := opts.hk_open_BuscaPMC
    hotkeys.ini["hotkeys", "default_user_hk"] := opts.edit_default_user_hotkey
    hotkeys.ini["hotkeys", "default_user_string"] := opts.edit_default_user_username " " opts.edit_default_user_password
    hotkeys.Reload(install_path)
}

CloseBadWindows(){
    windows := config.ini["windows_to_close", "windows"]
    if windows == "" or windows == "=" or windows == " "
        return
    windows := StrSplit(windows, ",;,")

    for window in windows{
        window := StrReplace(window, "   ", "")
        if window == "" or window == "=" or window == " " or window == "   "
            continue
        
        if WinExist(window)
            WinClose(window)
    }
}
try{
    ;SetTimer(CloseBadWindows, 500)
}

openBuscaPMC(args*){
    if not FileExist(buscaPMCPath)
        buscaGithub.DownloadLatest(install_path, buscaPMCRepo)
    Run(buscaPMCPath)
}

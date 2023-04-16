#SingleInstance Force
#Requires AutoHotkey v2.0

#Include "G:\Meu Drive\Repos\libraries"
#Include "Bruno-Functions\bruno-functions.ahk"
#Include "Bruno-Functions\IsOnline.ahk"
#Include "Bruno-Functions\Ini.ahk"
#Include "Bruno-Functions\DynamicClass.ahk"
#Include "Bruno-Functions\BatWrite.ahk"
#Include "Github-Updater.ahk\github-updater.ahk"


username := "TheBrunoCA"
repository := "SIM-Extra"
icon_url := "https://drive.google.com/uc?export=download&id=19RKBTniHoFkcezIGyH1SoClP5Zz4ADu0"
app_name := GetAppName()
extension := GetExtension()
hard_version := "0.11"
install_path := A_AppDataCommon "\" username "\" repository
install_full_path := install_path "\" A_ScriptName
install_bat := A_Temp "\install_bat.bat"
icon_id := StrSplit(icon_url, "id=")[2]
icon_path := install_path "\" icon_id ".ico"
icon_changed := FileExist(icon_path) == ""
is_installed := A_ScriptDir == install_path
was_installed := FileExist(install_bat) != ""
config := Configuration(install_path)
was_updated := config.ini["info", "version"] < hard_version
retroceded := config.ini["info", "version"] > hard_version

SetIcon()

if !is_installed
    InstallApp()

if config.auto_start
    SetAutoStart()

github := Git(username, repository, , true)
update_available := hard_version < github.GetVersion()

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
    try{
        FileDelete(install_bat)
    }
    catch Error as e{
        if FileExist(install_bat){
            if !A_IsAdmin{
                MsgBox("Ocorreu um problema na instalação, o aplicativo será reiniciado para corrigir.")
                if A_IsCompiled
                    Run '*RunAs "' A_ScriptFullPath '" /restart'
                else
                    Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
            }
            else{
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
    }
}

Class HotkeysConfig extends DynamicClass {
    __Load(dir_path) {
        this.dir_path := NewDir(dir_path)
        this.ini := Ini(dir_path "\hotkeys.ini")
        this.shutdown := this.ini["hotkeys", "shutdown", "^+q"]
        this.open_menu := this.ini["hotkeys", "open_menu", "^+m"]
        this.Enable()
    }

    Disable(){
        Hotkey(this.shutdown, "off")
        Hotkey(this.open_menu, "off")
    }

    Enable(){
        Hotkey(this.shutdown, ShutdownPc, "on")
        Hotkey(this.open_menu, OpenMenu, "on")
    }

    __BeforeReload(){
        this.Disable()
    }

}

ShutdownPc(ThisHotkey){
    asw := MsgBox("Deseja desligar o pc?", "Desligarás?", "0x4 0x1000 0x20")
    if asw == "Yes"
        Shutdown(13)
}

OpenMenu(ThisHotkey){
    MainGui.Show()
}

SetIcon(){
    if icon_changed{
        if IsOnline(){
            try{
                Download(icon_url, icon_path)
                TraySetIcon(icon_path)
                return
            }
        }
        TraySetIcon("*")
        return
    }
    TraySetIcon(icon_path)
}

InstallApp(){
    if !A_IsAdmin{
        MsgBox("Para ser instalado, o aplicativo precisa de privilégios de administrador.")
        if A_IsCompiled
            Run '*RunAs "' A_ScriptFullPath '" /restart'
        else
            Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
    }
    FileCreateShortcut(install_path "\" repository, A_Desktop "\" repository ".lnk", , , , A_IconFile)
    bat := BatWrite(install_bat)

    bat.TimeOut(1)
    bat.MoveFile(A_ScriptFullPath, install_path)
    bat.Start(install_full_path)

    MsgBox("O aplicativo será instalado agora, apenas aguarde.")
    Run bat.path, , "Hide"
    ExitApp(200)
}

UpdateApp(arg*){
    a := MsgBox("O aplicativo será atualizado.`nApenas aguarde.", repository, "t3")

    github.DownloadLatest(A_Temp, repository)
    bat.TimeOut(1)
    bat.MoveFile(install_full_path, install_path "\" repository "_old" github.GetExtension())
    bat.MoveFile(A_Temp "\" repository github.GetExtension(), install_full_path)
    bat.Start(install_full_path)

    Run bat.path, , "Hide"
    ExitApp(100)

}

SetAutoStart(){
    ;pedir coisa de admin
    ;criar atalho em commom startup
    if !A_IsAdmin{
        if A_IsCompiled
            Run '*RunAs "' A_ScriptFullPath '" /restart'
        else
            Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
    }

    FileCreateShortcut(install_full_path, A_StartupCommon "\" repository ".lnk", , , , A_IconFile)
}

MainGui := Gui("-MaximizeBox -MinimizeBox -Resize +OwnDialogs", repository " v-" hard_version)
MainGui.SetFont("s20")
MainGui.AddText("", repository " por " username)
MainGui.SetFont("s8")
tabs_main := MainGui.AddTab(, ["Geral", "Atalhos", "Configurações"])
tabs_main.UseTab(2)
MainGui.AddText(, "Atalho para desligar pc")
MainGui.AddHotkey("vhk_shutdown").Value := hotkeys.shutdown
MainGui.AddText(, "Atalho para abrir menu")
MainGui.AddHotkey("vhk_open_menu").Value := hotkeys.open_menu

tabs_main.UseTab(3)
MainGui.AddCheckbox("vckb_auto_update", "Atualizar automaticamente").Value := config.auto_update
MainGui.AddCheckbox("vckb_auto_start", "Abrir ao iniciar").Value := config.auto_start

tabs_main.UseTab()
btn_submit := MainGui.AddButton("xs", "Aplicar")
btn_submit.OnEvent("Click", MainGuiSubmit)
if update_available{
    MainGui.AddText("yp x+80", "Atualização disponível!")
    btn_update := MainGui.AddButton("yp+20 xp+25", "Atualizar")
    btn_update.OnEvent("Click", UpdateApp)
}

MainGuiSubmit(arg*){
    opts := MainGui.Submit(true)
    config.ini["update", "auto_update"] := opts.ckb_auto_update
    config.ini["config", "auto_start"] := opts.ckb_auto_start
    config.Reload(install_path)
    hotkeys.ini["hotkeys", "shutdown"] := opts.hk_shutdown
    hotkeys.ini["hotkeys", "open_menu"] := opts.hk_open_menu
    hotkeys.Reload(install_path)
}

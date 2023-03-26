#Requires AutoHotkey v2.0
#SingleInstance Force
SetWorkingDir A_ScriptDir
TraySetIcon("assets\icon.ico")

#Include lib\github.ahk
#Include lib\Native.ahk

; Caminho UserProfile
A_UserProfile := A_MyDocuments "\..\"

; Caminho para global_config.ini
vPathToGlobalConfig := A_UserProfile "\" A_ScriptName "\global-config.ini"

; Carrega as hotkeys
vHkDesligarPc := IniRead(vPathToGlobalConfig, "hotkeys", "desligar-pc", "^+q")

; Carrega as hotstrings
vHsLoginAuto := IniRead(vPathToGlobalConfig, "hotstrings", "login-auto", "bb")


; Menu de Configuracao
ConfigMenu := Gui("-Resize -MaximizeBox +OwnDialogs", "SIM-Extra by Bruno | Menu de Configurações")
ConfigMenu.SetFont("s20", "Courier New")
ConfigMenu.AddText("+Center", "SIM-Extra by Bruno")
ConfigMenu.SetFont()

; Tabs de configuração
ConfigTabs := ConfigMenu.AddTab(,["Hotkeys","HotStrings"])
ConfigTabs.UseTab(1)


ConfigMenu.AddGroupBox("xp+10 yp+20 h50", "Desligar o PC")
ConfigMenu.AddHotkey("xp+10 yp+20", vHkDesligarPc)

ConfigTabs.UseTab(2)

ConfigMenu.AddGroupBox("x35 y80 h50", "Login automático")
ConfigMenu.AddEdit("xp+10 yp+20 w100", vHsLoginAuto)

ConfigTabs.UseTab()

btnAplicar := ConfigMenu.AddButton("xs+90 w50 h30", "Aplicar")
btnCancelar := ConfigMenu.AddButton("xp+60 w50 h30", "Cancelar")

ConfigMenu.Show()

ConfigMenu.OnEvent("Close", fCloseConfig)

;Callback do evento Close
fCloseConfig(thisGui){
    ;MsgBox("Fechou")
}
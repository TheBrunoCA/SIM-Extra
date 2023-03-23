#Requires AutoHotkey v2.0
#SingleInstance Force
SetWorkingDir A_ScriptDir
TraySetIcon("assets\icon.ico")

; Caminho UserProfile
A_UserProfile := A_MyDocuments "\..\"

; Caminho para global_config.ini
vPathToGlobalConfig := A_UserProfile "\" A_ScriptName "\global-config.ini"

/* Carrega as configuracoes
@Param path Caminho para o arquivo de configuracao global
*/
fCarregaGlobalConfig(path){
    
}

; Menu de Configuracao
ConfigMenu := Gui("-Resize -MaximizeBox +OwnDialogs", "SIM-Extra by Bruno | Menu de Configurações")
ConfigMenu.SetFont("s20", "Courier New")
ConfigMenu.AddText("+Center", "SIM-Extra by Bruno")
ConfigMenu.SetFont()

; Tabs de configuração
ConfigTabs := ConfigMenu.AddTab(,["Hotkeys","HotStrings"])
ConfigTabs.UseTab(1)
ConfigMenu.AddText("x30 y90 w89 h23", "Desligar o PC")
hk_DesligarPC := ConfigMenu.AddHotkey("x105 y87")
ConfigTabs.UseTab(2)
ConfigMenu.AddText("x30 y90 w89 h23", "Teste")
hs_Teste := ConfigMenu.AddEdit("x105 y87")
ConfigMenu.AddText("x150 y110 w89 h23", "Para...")
hss_Teste := ConfigMenu.AddEdit("x40 y125 w280 h25")

ConfigMenu.Show()

ConfigMenu.OnEvent("Close", fCloseConfig)

;Callback do evento Close
fCloseConfig(thisGui){
    MsgBox("Fechou")
}
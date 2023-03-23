#Requires AutoHotkey v2.0
#SingleInstance Force
SetWorkingDir A_ScriptDir
TraySetIcon(A_Desktop . "\favicon.ico")

; Criando o menu
ConfigMenu := Gui("+AlwaysOnTop -Resize -MinimizeBox -MaximizeBox", "SIM-Extra by Bruno | Menu de Configurações")
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
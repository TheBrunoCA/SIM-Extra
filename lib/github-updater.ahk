#Include extra-functions.ahk

/*
 @Credit samfisherirl (https://github.com/samfisherirl/github.ahk)
*/
Class Git {
    __New(user, repo) {
        this.url := "https://api.github.com/repos/" user "/" repo "/releases/latest"
        this.body := DownloadToVar(this.url)
        this.body := FormatJsonToSimpleArray(this.body)
        if(this.body.Length < 2){
            this.is_online := false
            return
        }
        if(this.body[2] == "NotFound"){
            this.is_online := false
            return
        }
        this.is_online := true
        this.dl_url := GetKeyValueFromArray(this.body, "browser_download_url")
        this.version := GetKeyValueFromArray(this.body, "name")
        this.version := StrSplit(this.version, "v")
        this.version := this.version[this.version.Length]
        this.extension := StrSplit(this.dl_url, ".")
        this.extension := this.extension[this.extension.Length]
    }
    GetUrl(){
        return this.url
    }
    GetBody(){
        return this.body
    }
    GetDownloadUrl(){
        return this.dl_url
    }
    Download(path_to_save, filename){
        Download(this.dl_url, path_to_save "\" filename "." this.extension)
    }
    GetVersion(){
        return this.version
    }
    GetExtension(){
        return this.extension
    }
}

/*
Check on github for updates, for this to work there must be a release on the repository, 
with the version on the end of the name, such as this. "some-release-doesnt-matter v0.10"
IMPORTANT: There should be one or zero dots on the version. And any superior version should be a higher number
EX: v0.11 > v0.10 BUT < v0.12.
@Param &git_hub Reference to the github object.
@Param version_file Path to the version ini file.
*/
CheckUpdates(&git_hub, version_file){
    if(!git_hub.is_online){
        return
    }
    if(IsUpdated(&git_hub ,version_file)){
        return
    }
    answer := MsgBox("Uma nova versão do app foi encontrada, deseja atualizar?", "Versão " git_hub.GetVersion() " encontrada","0x4")
    if(answer == "Yes"){
        UpdateApp(&git_hub, GetAppName(), , , config_file)
        return
    }
    return
}

/*
Checks if the current installed version is up to date with the github latest release.
@Param &git_hub A reference to the github object.
@Param version_file The path to the version ini file.
@Return True if updated or False if not updated.
*/
IsUpdated(&git_hub ,version_file){
    if(FileExist(version_file) == ""){
        return false
    }
    if(IniRead(version_file, "version", GetAppName()) < git_hub.GetVersion()){
        return false
    }
    return true
}

/*
Downloads from github and replaces the executable or script
@Param &git_hub A reference to a github object
@Param app_name The executable's name on the directory
@Param update_message TODO: The message to be shown after updating.
@Param save_version TODO: Should save the version somewhere?
@Param version_path Where to save the version, it should be a .ini file
*/
UpdateApp(&git_hub, app_name, update_message := "",save_version := true, version_path := A_MyDocuments "\" app_name ".ini"){
    git_hub.Download(A_WorkingDir, app_name)
    IniWrite git_hub.GetVersion(), version_path, "version", app_name
    MsgBox("A Aplicação foi atualizada e será fechada automaticamente, por favor apenas reabra.", app_name " atualizado!")
    ExitApp()
}
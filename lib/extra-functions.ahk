/* Credit to jim U (https://stackoverflow.com/users/4695439/jim-u)
This basically converts an array into a single String
@Param strArray An array of strings. Not tested on other types of arrays.
@Param separator What should separate the elements.
@Return String Entire array on a single string separated by separator.
*/
ArrayToString(strArray, separator := "`n")
{
  s := ""
  for i,v in strArray
    s .= separator . v
  return substr(s, 3)
}

/*
@Returns The executable or script name, without extension.
*/
GetAppName(){
    return StrSplit(A_ScriptName, ".")[1]
}

/*
Downloads the page's content and returns it. Not Async.
@Param url The url for the page.
@Return The page's content
*/
DownloadToVar(url){
    whr := ComObject("MSXML2.XMLHTTP.6.0")
    whr.Open("GET", url, true)
    whr.Send()
    while(whr.readyState != 4){
        Sleep(100)
    }
    return whr.ResponseText
}

/*
Formats a json into a simple array
@Param json var containing json file
@Return Array
*/
FormatJsonToSimpleArray(json){
    text := StrReplace(json, "{", "")
    text := StrReplace(text, "}", "")
    text := StrReplace(text, " ", "")
    text := StrReplace(text, "`":", "`",")
    text := StrReplace(text, "`"", "")
    text := StrReplace(text, "[", "")
    text := StrReplace(text, "]", "")

    textArray := StrSplit(text, ",", " ")

    return textArray
}

/*
Gets a value from the next element in the first occurence of key.
@Param said_array The array in which to search.
@Param key The Key to search for in the array.
@Param default The default value in case "Key" is not found.
@Return The value from the key, or default if not found.
*/
GetKeyValueFromArray(said_array, key, default := ""){
    loop said_array.Length{
        if(said_array[A_Index] == key){
            return said_array[A_Index+1]
        }
    }
    return default
}


$ShareListToCreate = Import-Csv -Delimiter "`t" -Path $ShareCSVFile

 foreach ($ShareListToCreateItem in $ShareListToCreate){
    $strShare = $ShareListToCreateItem.NewShareName
    $strServer = $ShareListToCreateItem.NewFileServerName
    $strPath = $ShareListToCreateItem.NewSharePath
    
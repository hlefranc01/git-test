<#
.SYNOPSIS
.DESCRIPTION
Create a new share from CSV file data 001 002

.EXAMPLE
.\CreateShare.ps1 -ShareCSVFile .\ShareListToCreate.csv

.INPUTS
CSV file with the delimiter "tabulation" delimiter

.OUTPUTS
Error message if the share creation failed

.NOTES

.VERSION: 1.0
Author: HLE

Created On: 01/01/2024
LASTEDIT:

#>

Param(
# DFS Target CSV file to set Offline
[Parameter(Mandatory = $true)]
[Alias('CSVFile')] [string] $ShareCSVFile
)


function CreateShareServer(){
#------------------------------------------------------------------------------------------------------
#  Create share on server
#------------------------------------------------------------------------------------------------------
$error.Clear()
$ErrorActionPreference="Stop"
## Create Folder


$ShareBlockcommand = {param($LShare, $LPath)
## Create Folder
#write-host "LShare : " $LShare
#write-host "LPath : " $LPath

If (!(test-path $LPath))
{
    Write-Host "Creating folder `"$LPath`" ..." -ForegroundColor green
    New-Item -Path $LPath -ItemType directory
}
else
{
    Write-Host "The folder `"$LPath`" already exists" -ForegroundColor Yellow
}
 
## Create Share
If (!(Get-SmbShare -Name $LShare -ErrorAction SilentlyContinue))
{
    Write-Host "Creating `"$LShare`" share ..."  -ForegroundColor green
    New-SmbShare –Name $LShare –Path $LPath

    Write-Host "Revoking `"$LShare`" permissions share ..."  -ForegroundColor green
    Revoke-SmbShareAccess -Name $LShare -AccountName "Everyone" -Force

    Write-Host "Granting read only `"NT AUTHORITY\Authenticated Users`" permission to `"$LShare`" share ..."  -ForegroundColor green
    Grant-SmbShareAccess -Name $LShare -AccountName "NT AUTHORITY\Authenticated Users" -AccessRight Change -Force

    Write-Host "Granting full control `"BUILTIN\Administrators`" permission to `"$LShare`" share ..."  -ForegroundColor green
    Grant-SmbShareAccess -Name $LShare -AccountName "BUILTIN\Administrators" -AccessRight Full -Force

    Write-Host "Removing cache mode on `"$LShare`" share ..."  -ForegroundColor green
    Set-SMBShare -Name $LShare -CachingMode None -Confirm:$False
}
else
{
    Write-Host "The share `"$LShare`" already exists" -ForegroundColor Yellow
}

}
try
{
Invoke-Command -ComputerName $strServer -scriptblock $ShareBlockcommand -ArgumentList $strShare,$strPath
}
catch
{
Write-Warning -Message "$($_.Exception.Message)"
}


}


# Main program

$ShareListToCreate = Import-Csv -Delimiter "`t" -Path $ShareCSVFile

 foreach ($ShareListToCreateItem in $ShareListToCreate){
    $strShare = $ShareListToCreateItem.NewShareName
    $strServer = $ShareListToCreateItem.NewFileServerName
    $strPath = $ShareListToCreateItem.NewSharePath
        
    Write-Host "Server name  : `"$strServer`""
    Write-Host "Path share   : `"$strPath`""
    write-Host "Share name   : `"$strShare`""    
    CreateShareServer

    }


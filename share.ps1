<#
    .SYNOPSIS
    This script creates a shared folder and grants access to it.

    .DESCRIPTION
    The script creates a shared folder at the specified path and grants access to it. If the folder does not exist, it will be created.

    .PARAMETER folderPath
    Specifies the full path of the folder to be shared.

    .PARAMETER shareName
    Specifies the name for the shared folder.

    .PARAMETER userName
    Specifies the name of the user to grant access to the shared folder.

    .EXAMPLE
    CreateAndGrantShare -folderPath "C:\Shared" -shareName "Data" -userName "Fomin_Danil"
    This example creates a shared folder at "C:\Shared" with the name "Data" and grants access to the user "Fomin_Danil".

    .NOTES
    File Name: share.ps1
    Author   : Fomin Danil (AB-124)
    Version  : 1.5
    Date     : 04.12.2023
#>

[CmdletBinding()]
param (
    [Parameter(mandatory=$true)]
    [string]$folderPath,
    [Parameter(mandatory=$true)]
    [string]$shareName,
    [Parameter(mandatory=$false)]
    [string]$userName = $null,
    [switch]$help
)
    
if ($help) {
    Get-Help $MyInvocation.MyCommand.Definition
    exit
}

function CreateSharedFolder {
    param (
        [string]$folderPath,
        [string]$shareName
    )

    if (-not (Test-Path $folderPath)) {
        New-Item -ItemType Directory -Path $folderPath
        Write-Host "Created a new folder at the specified path"
    }

    New-SmbShare -Name $shareName -Path $folderPath -FullAccess 'Everyone'
}


function GrantShareAccess {
    param (
        [string]$shareName,
        [string]$userName,
        [string]$folderPath
    )

    if (-not (Get-SmbShare -Name $shareName)) {
        Write-Host "The specified shared resource does not exist! Creating a new one..."

        $shareDescription = "Shared Folder"
        New-SmbShare -Name $shareName -Path $folderPath -Description $shareDescription -ReadAccess 'Everyone'
    }

    if (-not (Get-LocalUser -Name $userName)) {
        Write-Host "The specified user was not found!"
        exit
    }

    Grant-SmbShareAccess -Name $shareName -AccountName $userName -AccessRight Read
}


if (-not $folderPath) {
    $folderPath = Read-Host "Please specify the full path of the folder"
}
    
if (-not $shareName) {
    $shareName = Read-Host "Please specify the name of the shared resource"
    exit
}
    
CreateSharedFolder -folderPath $folderPath -shareName $shareName
        
if ($userName) {
    GrantShareAccess -shareName $shareName -userName $userName -folderPath $folderPath
}



    







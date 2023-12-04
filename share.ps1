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
    Version  : 1.53
    Date     : 04.12.2023
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$folderPath,
    [Parameter(Mandatory=$true)]
    [string]$shareName,
    [Parameter(Mandatory=$false)]
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

    if (Get-SmbShare -Name $shareName -ErrorAction SilentlyContinue) {
        Write-Host "The specified shared resource already exists! Removing the existing one..."
        Remove-SmbShare -Name $shareName -Force
    }

    if (-not (Get-SmbShare -Name $shareName -ErrorAction SilentlyContinue)) {
        Write-Host "Creating a new shared resource..."

        if (-not (Test-Path $folderPath)) {
            New-Item -ItemType Directory -Path $folderPath
            Write-Host "Created a new folder at the specified path"
        }

        $shareDescription = "Shared Folder"
        New-SmbShare -Name $shareName -Path $folderPath -Description $shareDescription
    }
}

function GrantShareAccess {
    param (
        [string]$shareName,
        [string]$userName
    )

    if (-not (Get-LocalUser -Name $userName -ErrorAction SilentlyContinue)) {
        Write-Host "The specified user was not found!"
        exit
    }

    if (-not (Get-SmbShare -Name $shareName -ErrorAction SilentlyContinue)) {
        Write-Host "The specified shared resource does not exist!"
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
    GrantShareAccess -shareName $shareName -userName $userName
}



    







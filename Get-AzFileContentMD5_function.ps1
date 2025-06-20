Import-Module Az.Storage -ErrorAction Stop
Add-Type -AssemblyName "Microsoft.WindowsAzure.Storage"

function Get-AzFileContentMD5 {
    param (
        [Parameter(Mandatory)] [string] $ResourceGroupName,
        [Parameter(Mandatory)] [string] $StorageAccountName,
        [Parameter(Mandatory)] [string] $FileShareName,
        [Parameter(Mandatory)] [string] $FilePath
    )

    $key = (Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName)[0].Value
    $cloudStorageAccount = [Microsoft.WindowsAzure.Storage.CloudStorageAccount]::Parse("DefaultEndpointsProtocol=https;AccountName=$StorageAccountName;AccountKey=$key;EndpointSuffix=core.windows.net")
    $client = $cloudStorageAccount.CreateCloudFileClient()
    $share = $client.GetShareReference($FileShareName)

    $dirPath = [System.IO.Path]::GetDirectoryName($FilePath).Replace("\", "/")
    $fileName = [System.IO.Path]::GetFileName($FilePath)

    $rootDir = $share.GetRootDirectoryReference()
    $dir = $rootDir.GetDirectoryReference($dirPath)
    $file = $dir.GetFileReference($fileName)

    $file.FetchAttributesAsync().GetAwaiter().GetResult()
    return $file.Properties.ContentMD5
}

# Example test call (edit or prompt)
$rg = Read-Host "Enter Resource Group Name"
$sa = Read-Host "Enter Storage Account Name"
$share = Read-Host "Enter File Share Name"
$path = Read-Host "Enter File Path"


Get-AzFileContentMD5 -ResourceGroupName $rg -StorageAccountName $sa -FileShareName $share -FilePath $path
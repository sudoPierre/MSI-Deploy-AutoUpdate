# Replace with the full path of the folder GpoSoftInstaller : "c:\programs\GpoSoftInstaller"
$FullPath = "."

# importing the CSV file that contains the links to the MSI packages
$LinksFile = Import-CSV -Path "$FullPath\packagesLinks.csv" -Delimiter ";"

# run through the CSV file to download the MSI packages
foreach($LINE in $LinksFile)
{
    $packageName = $LINE.NAME
    $packageLink = $LINE.LINK
    
    # Download the MSI package to the buffer zone
    (new-object Net.WebClient).DownloadFile($packageLink, "$FullPath\bufferZone\$packageName.msi")
    if($?) {
        CreateANewLogEntry -State "Successful" -InputContent "MSI package $packageName downloaded successfully to buffer zone."

        # Verification of the presence of the package in the updatedPackages folder
        if(Test-Path "$FullPath\updatedPackages\$packageName.msi"){

            # We retrieve the version number of the old package
            $oldVersion = Get-AppLockerFileInformation -Path "$FullPath\updatedPackages\$packageName.msi" | Select-Object -ExpandProperty Publisher | Select-Object BinaryVersion
        } else {
            $oldVersion = "none"
        }
        # We retrieve the version number of the new package
        $newVersion = Get-AppLockerFileInformation -Path "$FullPath\bufferZone\$packageName.msi" | Select-Object -ExpandProperty Publisher | Select-Object BinaryVersion
        
        # If the version number has not changed, we do nothing
        if ($oldVersion.ToString() -eq $newVersion.ToString()) {
            CreateANewLogEntry -State "Checking" -InputContent "$packageName package is already the newest version."
        } else {
            CreateANewLogEntry -State "Checking" -InputContent "New version available for $packageName."

            # If the version number has changed, we delete the old package and move the new package to the updatedPackages folder
            if(Test-Path "$FullPath\updatedPackages\$packageName.msi"){
                Remove-Item -Path $FullPath\updatedPackages\$packageName.msi
                if($?) {
                    CreateANewLogEntry -State "Successful" -InputContent "Successfully removed the $packageName old package."
                    Move-Item -Path $FullPath\bufferZone\$packageName.msi -Destination .\updatedPackages\$packageName.msi
                    if($?) {
                        CreateANewLogEntry -State "Successful" -InputContent "$packageName package successfully updated."
                    } else {
                        CreateANewLogEntry -State "Fail" -InputContent "failed to updating $packageName package."
                    }
                } else {
                    CreateANewLogEntry -State "Fail" -InputContent "failed to remove $packageName old package."
                }
            } else {
                Move-Item -Path "$FullPath\bufferZone\$packageName.msi -Destination .\updatedPackages\$packageName.msi"
                if($?) {
                    CreateANewLogEntry -State "Successful" -InputContent "$packageName package successfully updated."
                } else {
                    CreateANewLogEntry -State "Fail" -InputContent "failed to updating $packageName package."
                }
            }
        }
    }
    else
    {
        CreateANewLogEntry -State "Fail" -InputContent "Failed to download MSI package $packageName to buffer zone."
    }

    # Erase the package from the buffer zone
    Remove-Item -Path "$FullPath\bufferZone\$packageName.msi"
    if($?){
        CreateANewLogEntry -State "Successful" -InputContent "$packageName package successfully erased from buffer zone."
    } else {
        CreateANewLogEntry -State "Fail" -InputContent "Failed to erase MSI package $packageName from buffer zone."
    }
}

# Function to create a new log entry
function CreateANewLogEntry{
    Param
    (
         [Parameter(Mandatory=$true, Position=0)]
         [string] $State,
         [Parameter(Mandatory=$true, Position=1)]
         [string] $InputContent
    )
    $currentDate = Get-Date -Format "dd-MM-yyyy_HH:mm"
    $currentContent = Get-Content -Path $FullPath\logs.txt
    $newContent = @()
    $newContent += "$currentDate - $State - $InputContent"
    $newContent += $currentContent
    $newContent | Out-File "$FullPath\logs.txt"
}
# Specify the distinguished name of the OU below which you want to delete user profiles
$targetOU = "OU=Districts,DC=apps,DC=clackesd,DC=k12,DC=or,DC=us"

# Import the Active Directory module
Import-Module ActiveDirectory

$profiles = Get-WmiObject Win32_UserProfile | Where-Object { $_.Special -eq $false -and $_.LocalPath -like "C:\Users\*" } | ForEach-Object {
    $profileSID = $_.SID
    $user = Get-ADUser -Filter { SID -eq $profileSID } -Properties DistinguishedName
    if ($user.DistinguishedName -like "*,$targetOU") {
        $_
        }
    }

# Iterate through each profile below the specified OU

foreach ($profile in $profiles) {
    # Check if the user is logged in

    $loggedIn = quser /server:localhost | Where-Object { $_ -match $profile.LocalPath.Split('\')[2] }
    #Write-Host "Logged in: $($loggedIn)"

    # If the user is not logged in, delete the profile
    
    if (-not $loggedIn) {
        #Write-Host "Would be deleting profile: $($profile.LocalPath)"
        Remove-WmiObject -InputObject $profile -WhatIf # Use -WhatIf to simulate, remove it to perform actual deletion
        }
    else {
        Write-Host "Not Deleting profile: $($profile.LocalPath) logged in!"
        }
    }

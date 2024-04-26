# Specify the distinguished name of the OU below which you want to delete user profiles
$targetOU = "OU=Districts,DC=apps,DC=clackesd,DC=k12,DC=or,DC=us"

# Import the Active Directory module
Import-Module ActiveDirectory

# Get a list of user profiles below the specified OU
$profiles = Get-WmiObject Win32_UserProfile | Where-Object { $_.Special -eq $false -and $_.LocalPath -like "C:\Users\*" } | ForEach-Object {
    $profileSID = $_.SID
    $user = Get-ADUser -Filter { SID -eq $profileSID } -Properties DistinguishedName
    if ($user.DistinguishedName -like "*,$targetOU") {
        $_
    }
}

# Iterate through each profile below the specified OU
foreach ($profile in $profiles) {
    # Check if the profile is loaded (i.e., the user is logged in)
    $loaded = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$($profile.LocalPath.Split('\')[1])"

    # If the profile is not loaded (user logged off), delete it
    if (-not $loaded) {
        Write-Host "Deleting profile: $($profile.LocalPath)"
        #Remove-WmiObject -InputObject $profile -WhatIf # Use -WhatIf to simulate, remove it to perform actual deletion
        }
    else {
        Write-Host "Not Deleting profile: $($profile.LocalPath) logged in!"
        }
    }

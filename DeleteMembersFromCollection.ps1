<#
##==============================================
## Written by: Naveen Bhurli
## Written on: 23-March-2020
##==============================================
#>

# importing/Adding Forms module, so that a GUI is possible
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationCore,PresentationFramework

# Connecting to SCCM server and importing required modules
Import-Module (Join-Path $(Split-Path $env:SMS_ADMIN_UI_PATH) ConfigurationManager.psd1)
$SiteCode = Get-PSDrive -PSProvider CMSITE
$SMSProvider = $sitecode.SiteServer
Set-Location "$($SiteCode.Name):\"


# This is the main form where all the buttons and things are added later down below
$mainForm = New-Object System.Windows.Forms.Form

# A mandatory icon so people think I am not newbie
$MainIcon = [system.drawing.icon]::ExtractAssociatedIcon($PSHOME + "\powershell.exe")
$MainForm.Icon = $MainIcon

# Adding functioning stuff like textbox to write, buttons to press
$mainForm.Text = "Get Members from Collection"
$mainForm.Width = 300
$mainForm.Height = 300
$mainForm.AutoSize = $true
$mainForm.StartPosition = "CenterScreen"
$mainForm.MaximizeBox = $false
$mainForm.MinimizeBox = $false
$mainform.Sizegripstyle = "Hide"
$mainform.FormBorderStyle = "Fixed3D"



$Label = New-Object System.Windows.Forms.Label
$Label.Text = "Collection Name:"
$Label.Location = New-Object System.Drawing.Point(10,50)
$mainForm.Controls.Add($Label)

# this is the box where you are allowed to write
$collectionInput = New-Object System.Windows.Forms.TextBox
$collectionInput.Location = New-Object System.Drawing.Point(120,50)
$collectionInput.Size = New-Object System.Drawing.Size(150,20)

$mainForm.Controls.Add($collectionInput)

# Mandatory "Cancel" button to cancel and close everythin (because we are too busy to press "x")
$exitButton = New-Object System.Windows.Forms.Button
$exitButton.Text = "Exit"
$exitButton.Location = New-Object System.Drawing.Point(160,150)
$exitButton.Size = New-Object System.Drawing.Point(75,23)
$mainForm.Controls.Add($exitButton)


# Mandatory "OK" button which does the thing we want
$okButton = New-Object System.Windows.Forms.Button
$okButton.Text = "OK"
$okButton.Location = New-Object System.Drawing.Point(50,150)
$okButton.Size = New-Object System.Drawing.Point(75,23)
$mainForm.Controls.Add($okButton)




# Giving life to "OK" button

$okButton.Add_Click(
{
    
    # Fetching only the text from Input
    $collectionName = $collectionInput.Text

    #Adding a button so that you have a second chance for verifying before messing things up

    $ButtonType = [System.Windows.MessageBoxButton]::YesNo
    $MessageIcon = [System.Windows.MessageBoxImage]::Question
    $MessageBody = "Are you sure you want to delete all the members from collection: '$collectionName'?"
    $MessageTitle = "Confirm Deletion"

    $Result = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)

    if($Result -eq "Yes")
    {
        
        $collectionName = $collectionInput.Text
        # Checking if the given collection exist
        $colexist = Get-CMDeviceCollectionDirectMembershipRule -CollectionName "$collectionName"

        if($colexist)
        {
            
            $collectionName = $collectionInput.Text
            
            # Actual Command that deletes all the members from the given collection
            $res = Get-CMDeviceCollectionDirectMembershipRule -CollectionName $collectionName | Select ResourceID | ForEach-Object {Remove-CMDeviceCollectionDirectMembershipRule -CollectionName $collectionName -ResourceID $_.ResourceID -Force} 
            
            if($?)
            {
                # Everything went well, as expected (Phew...)
                $ButtonType = [System.Windows.MessageBoxButton]::OK
                $MessageIcon = [System.Windows.MessageBoxImage]::Information
                $MessageBody = "Successfully deleted all the members from collection: '$collectionName'"
                $MessageTitle = "Success"
                $SuccessResult = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)
            
            }
            else
            {
                # Uh oh, not sure what happened but something went south
                $ButtonType = [System.Windows.MessageBoxButton]::OK
                $MessageIcon = [System.Windows.MessageBoxImage]::Error
                $MessageBody = "unfortunately, there was some error. Please try again.."
                $MessageTitle = "Fail"
                $FailResult = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)

            }
        }
        else
        {
                # Incorrect Collection name entered or collection does not exist
                $ButtonType = [System.Windows.MessageBoxButton]::OK
                $MessageIcon = [System.Windows.MessageBoxImage]::Error
                $MessageBody = "This collection: '$collectionName' has no members in it or the collection does not exist."
                $MessageTitle = "Empty / no Collection"
                $FailResult = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)


        }


    }



})

$exitButton.Add_Click({
$mainForm.Close() | Out-Null


})





$mainForm.ShowDialog() | Out-Null

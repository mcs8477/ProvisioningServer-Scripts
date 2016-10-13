#  Purpose: Mount a specific ISO to all the VM's on a VMware environment.
#           Useful for PVS environments that use Boot ISO's instead of PXE boot
# 
#  Author : MCS8477
#  Version: 1.0 
#  Release: 10/13/2016                                                         
#
# ============================================================================================

　
# ======================================================================
# -- C O N S T A I N T S
# ======================================================================
$VCs = "vCenterSrv01.mydomain.local","vCenterSrv02.mydomain.local"
　
# ** Set this to $true to set the value of the CD-ROM drive, otherwise if $false it will just create a report
$SetValue = $false
　
# ** "Images" is the name of the DataStore in vCenter, "cd" is the folder, "7-6PVS-Boot.iso" is the ISO file
$ISOpath = "[Images] cd/7-6PVS-Boot.iso"
　
# ** Export file values
$CDromStatusReport = ".\CDrom-Status.csv"
　
# ======================================================================
# -- F U N C T I O N S
# ======================================================================

# ======================================================================
# -- M A I N
# ======================================================================
cls
# ****************************************************************************
# ** Add the required PowerShell modules
# ****************************************************************************
Import-Module VMware.VimAutomation.Sdk
Import-Module VMware.VimAutomation.Core
　
# ****************************************************************************
# ** Provide vCenter Credentials
# ****************************************************************************
cls
$MyCred = Get-Credential -Message "Please provide vCenter credentials" -UserName "$ENV:USERDOMAIN\$ENV:USERNAME"
　
# ** Connect to vCenters
foreach ($vc in $VCs) {
	#Write-Host "Connecting to " $vc.Name
	Connect-VIServer $vc.Name -credential $MyCred | Out-Null
　
	# ** Get all VMs (May want to provide some filters, or other ways to limit the results here)
	$Computers = Get-VM
　
	Write-Host "Checking CD-ROM settings on All computers..." 
　
	# *** Looping the the VMs and Documenting the current values, prior to setting them
	# *** Export to CSV file, so they could be used as input to a script to reset values to current state
	foreach ($Computer in $Computers) {
		$CDROM = Get-CDDrive -VM $Computer
		$CDROM | Export-Csv -Path $CDromStatusReport -NoTypeInformation -Append
　
		if ($SetValue) {
			# ** Ejects media from CD-ROM drive
			#set-cddrive -cd $CDROM -NoMedia:$true -confirm:$false

			# ** The Following will insert the CD-ROM ISO in the VMs CD-ROM drive, IMMEDIATELY OVERWRITING the current value without further prompting
			if ($Computer.PowerState -eq "PoweredOn") {
				# ** Inserts media (ISO) in the CD-ROM drive and sets it to connected
				Set-CDDrive -cd $CDROM -ISOPath $ISOpath -Connected:$true -confirm:$false	
			} # END if "PoweredOn"
			else {
				# ** Inserts media (ISO) in the CD-ROM drive (CanNOT set to connected if VM is powered off, but is set to "StartConnected")
				Set-CDDrive -cd $CDROM -ISOPath $ISOpath -confirm:$false	
			} # END else if "PoweredOn"		
		
		} # END if $SetValue
		
	} # END foreach $Computer	
	
	Write-Host "Disconnecting from " $vc
	Disconnect-VIServer $vc.Name | Out-Null
} # END foreach $vc

# ======================================================================
# -- END
# ======================================================================
Write-Host "@@@  F I N I S H E D    S C R I P T   @@@"
　

#  Purpose: Replicated Local Store PVS vDisks to all PVS servers
#
#  Author : mcs8477
#  Version: 1.0 
#  Release: 07/15/2016                                                         
#
# ============================================================================================

# ======================================================================
# -- C O N S T A I N T S
# ======================================================================
$colFiles = @()  # - Array to hold the File Objects
$RobocopyParms = "/COPY:DAT /XF ~*, *.bak, *.tmp, *.lok"

# ======================================================================
# -- F U N C T I O N S
# ======================================================================

Function CheckSystemTime ($server) {
		$dt = gwmi win32_operatingsystem -computer $server
		$dt_str = $dt.converttodatetime($dt.localdatetime)
		write-host "$($server) time is $($dt_str)"
} # END CheckSystemTime

Function Get-ListOfItemsFromUser {
# ============================================================================================
# -- Get-ListOfItemsFromUser
# ============================================================================================
#	Description: Loop to gather input and place items into an array/collection
#
#	Parameters:
#		None
#		
#	Example Use:
#		Get-ListOfItemsFromUser
# ============================================================================================
Param (
		[Parameter(Mandatory=$true)]
		[String] $ItemType
	) # END Param block
	$Items = @()
	$Done = $false
	
	do {
		cls
		Write-Prompt "Please enter a $ItemType (One at a time)"
		Write-Prompt "OR leave blank if done, Followed by [ENTER]" 
		Write-Prompt " "
		Write-Prompt "================================================="
		Write-Prompt " " 

		if ($Items) {
			Write-Prompt "Currently Entered $ItemType(s):" 
			foreach ($Item in $Items) {
				write-host $Item -BackgroundColor Gray -ForegroundColor Black
			} # END foreach $Item
			Write-Prompt " " 
			Write-Prompt "================================================="
		} # END if $Items

		$NewItem = Read-Host 
		if ($NewItem) {
			$Items += $NewItem
		} # END if $Item (was entered)
		else {
			$Done = $true
		}
	} # End do
	Until ($Done)
	return $Items
	
} # END Get-ListOfItemsFromUser

Function Get-vDiskName () {
	cls
	write-Prompt "************************************************************" 
	Write-Prompt "This script will search the local store on each PVS server" 
	Write-Prompt "in the list of server for a specified vDisk and determine" 
	Write-Prompt "the current version to replicate to the other PVS stores." 
	Write-Prompt "************************************************************" 
	Write-Prompt "Type a unique portion of the vDisk name, followed by [ENTER]" 
	Write-Prompt "    For example:  MarketingDesktop" 
	Write-Prompt " "
	$vDiskName = Read-Host
	$vDiskName = "*" + $vDiskName + "*.*vhd"
	Write-Host " "
	Return $vDiskName
	
} # END Get-vDiskName

Function Get-Repository () {
	cls
	Write-Prompt "Provide the share name and path to the vDisk Repository" 
	Write-Prompt "on each server, followed by [ENTER]." 
	Write-Prompt "    For example:  D$\vDisks" 
	Write-Prompt " "
	$ShareName = Read-Host
	Write-Host " "
	Return $ShareName

} # END Get-Repository

Function Get-YesOrNo {
# ============================================================================================
# -- Get-YesOrNo
# ============================================================================================
#	Parameters:
#		$PromptStr - Yes or No question in string format
#
#	Example Use:
#		Get-YesOrNo "Create Virtual Machine ???"
# ============================================================================================
	Param (
		[Parameter(Mandatory=$true)]
		[String] $PromptStr
	) # END Param block
	
	Write-Host " "
	Write-Host $PromptStr -BackgroundColor Blue -ForegroundColor White
	Write-Host "  -- Please type (" -BackgroundColor Blue -ForegroundColor White -NoNewline
	Write-Host "Y" -BackgroundColor Blue -ForegroundColor Green -NoNewline
	Write-Host "es/" -BackgroundColor Blue -ForegroundColor White -NoNewline
	Write-Host "N" -BackgroundColor Blue -ForegroundColor Red -NoNewline
	Write-Host "o), Followed by [ENTER] " -BackgroundColor Blue -ForegroundColor White 
	$Continue = Read-Host

	if ($Continue -like "Y*") {
		$true
		}
	else {
		$false
	}	# End IF
} # END Get-YesOrNo

Function ReplicateVdisk {
# ============================================================================================
# -- ReplicateVdisk
# ============================================================================================
#	Description: Loop to gather input and place items into an array/collection
#
#	Parameters:
#		$FileName	Full name of file to replicate
#		$SourceSvr	Name of PVS server to be used as the source for replication
#		
#	Example Use:
#		ReplicateVdisk $NewestVdisk $NewestVdiskSvr
# ============================================================================================
Param (
		[Parameter(Mandatory=$true)]
		[String] $FileName,
		[Parameter(Mandatory=$true)]
		[String] $SourceSvr
	) # END Param block

	# ** Remove file extention from $FileName
	$SplitFileName = $FileName.split('.')
	# ** Loop rebuilds FileName but replaces the extention with "*"
	$cnt = 0
	Do {
		$ReplFiles = $ReplFiles + $SplitFileName[$cnt] + "."
		$cnt++
		} while ($cnt -lt ($SplitFileName.length -1))
		# ** End Loop
	$ReplFiles = $ReplFiles + "*"
	$SrcRepository = '"\\' + $SourceSvr + '\' + $vDiskShare + '"'
	
	foreach ($PVSServer in $PVSServers) {
		if ($PVSServer -ne $SourceSvr) {
			$DestRepository = '"\\' + $PVSServer + '\' + $vDiskShare + '"'
			$ArgumentString = $SrcRepository + " " + $DestRepository + " " + $ReplFiles + " " + $RobocopyParms
			Start-Process -Wait -FilePath robocopy.exe -ArgumentList $ArgumentString -NoNewWindow
		} #End IF
	} #End ForEach
	
} #End ReplicateVdisk

Function Write-Prompt () {
Param (
		[Parameter(Mandatory=$true)]
		[String] $PromptLine
	) # END Param block

	$PromptLength = 65
	
	if ($PromptLine.Length -lt $PromptLength) {
		$PadLength = $PromptLength - $PromptLine.length
		# ** PadRight not working correctly, needed to force behavior
		$NewPromptLine = $PromptLine + ' '.PadRight($PadLength)
		Write-Host $NewPromptLine -BackgroundColor Blue -ForegroundColor White
	} # END If 
	else {
		Write-Host $PromptLine -BackgroundColor Blue -ForegroundColor White
	}
} # END Write-Prompt

# ======================================================================
# -- M A I N
# ======================================================================

# ** Prompt for a vDisk to work with
$vDiskName = Get-vDiskName 

# ** Prompt for list of PVS servers
$PVSServers = Get-ListOfItemsFromUser "PVS Server"

# ** Prompt for PVS Server Share Name
$vDiskShare = Get-Repository
#$vDiskShare = "D$\vDisks"

cls
Write-Prompt "Gathering list of vDisks containing ($vDiskName)..."
foreach ($PVSServer in $PVSServers) {
	$Files = dir \\$PVSServer\$vDiskShare\$vDiskName
	# ** If new vDisk, result of $Files might be empty for most servers
	if ($Files) {
		foreach ($File in $Files) {
			# -- Create the new object for a File
			$objFile = New-Object System.Object
			$objFile | Add-Member -type NoteProperty -Name PVSserver -Value $PVSServer
			$objFile | Add-Member -type NoteProperty -Name FileName -Value $File.Name
			$objFile | Add-Member -type NoteProperty -Name FileSize -Value $File.Length
			$objFile | Add-Member -type NoteProperty -Name FileModDate -Value $File.LastWriteTime
			$objFile | Add-Member -type NoteProperty -Name Newest -Value $null
			# -- Add File Object into Array
			$colFiles += $objFile
		} # End foreach File
	} # END if $Files
	else {
		Write-Host "No vDisk Files on" $PVSServer "contain (" $vDiskName ")" -BackgroundColor Yellow -ForegroundColor Black
	} # END Else $Files (No files found)
} # End foreach PVSserver

# ** Checking to make sure some files were found that match the search
if ($colFiles) {
	Write-Prompt " "
	Write-Prompt " Determining most recent vDisk version..."
	Write-Prompt " "
	# ** Sorting list of files in decending order by Modification Date should result in the newest version of the file
	$FileList = $colFiles | select FileName,FileSize,FileModDate,PVSserver,Newest | Sort-Object -Property FileModDate,FileName -Descending
	$NewestVdisk = $FileList[0].FileName
	$NewestVdiskSvr = $FileList[0].PVSserver
	# ** Flagging the newest entry in the file list collection
	$FileList[0].Newest = $true
	Write-Prompt " -- Newest vDisk: $NewestVdisk"
	Write-Prompt " --   PVS Server: $NewestVdiskSvr"
	Write-Prompt " -------------------------------------------------------------"
	Write-Prompt " "
	## ** Filters the list of files found to ONLY the files that match the file name of $NewestVersion
	$FilteredFileList = $FileList | where {$_.FileName -eq $NewestVdisk}

	Write-Prompt "Status of Newest vDisk:"
	Write-Prompt " "
	$FilteredFileList | Format-Table

} # END if $colFiles
else {
	Write-Host " "
	Write-Host " No vDisks matching the description were found on the PVS Servers" -BackgroundColor Red -ForegroundColor White
} # END else $colFiles (No files found on any server)

$BeginReplication = Get-YesOrNo "Would you like to begin replication of vDisk files?"
if ($BeginReplication -eq "Yes"){
	if ($NewestVdiskSvr -eq $env:COMPUTERNAME) {
		Write-Host "Running replication from server..." $NewestVdiskSvr
		ReplicateVdisk $NewestVdisk $NewestVdiskSvr
	} # End If $NewestVdiskSvr is LOCAL server
	else {
		Write-Host " -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ -- "
		Write-Host " -- @"
		Write-Host " -- @   W A R N I N G:  Script is being executed from a computer "
		write-host " -- @        that does NOT contain the NEWEST vDisk and may result"
		Write-Host " -- @        in a slower replication. " 
		Write-Host " -- @"
		Write-Host " -- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ -- "
		$continue = Get-YesOrNo "Would you like to begin replication of vDisk files anyway?"
		if ($continue -eq "Yes") {
			ReplicateVdisk $NewestVdisk $NewestVdiskSvr
		} # END $continue [anyway]
	} # End Else $NewestVdiskSvr is not Local server
} # End if $BeginReplication

# ======================================================================
# -- E N D
# ======================================================================
Write-Host " "
write-host " @@@  Finished Script @@@"

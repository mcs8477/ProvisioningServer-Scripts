#  Purpose: Replicate Local Store PVS vDisks to all PVS servers
#
#  Author : mcs8477
#  Version: 2.0 
#  Release: 07/15/2016                                                         
#
# ============================================================================================

# ======================================================================
# -- C O N S T A N T S
# ======================================================================
$colFiles = @()  # - Array to hold the File Objects
$RobocopyParms = "/COPY:DAT /XF ~*, *.bak, *.tmp, *.lok /R:2 /W:10"

# ================================================
# -- PVS Server Environments
# ================================================
# ** Array of the PVS Servers
$PVSsvrList = @()
# ** Create the properties for PVS Server objects
$PVSsvrProperties = @{
	Name=$null
	Domain=$null
	Version=$null
	Repository=$null
	DataCenter=$null
	}
	#** Populate a new PVS Server object with values
	$PVSobj = New-Object PSObject -Property $PVSsvrProperties
		$PVSobj.Name="PVSsrv01"
		$PVSobj.Domain="somedomain.com"
		$PVSobj.Version="7.x"
		$PVSobj.Repository="\\" + $PVSobj.Name + "." + $PVSobj.Domain + "\D$\vDisks"
		$PVSobj.DataCenter="CA"
		# Add PVS object to PVS Server List collection (array)
		$PVSsvrList += $PVSobj
	#** Populate a new PVS Server object with values
	$PVSobj = New-Object PSObject -Property $PVSsvrProperties
		$PVSobj.Name="PVSsrv02"
		$PVSobj.Domain="somedomain.com"
		$PVSobj.Version="7.x"
		$PVSobj.Repository="\\" + $PVSobj.Name + "." + $PVSobj.Domain + "\D$\vDisks"
		$PVSobj.DataCenter="CA"
		# Add PVS object to PVS Server List collection (array)
		$PVSsvrList += $PVSobj
	#** Populate a new PVS Server object with values
	$PVSobj = New-Object PSObject -Property $PVSsvrProperties
		$PVSobj.Name="PVSsrv03"
		$PVSobj.Domain="somedomain.com"
		$PVSobj.Version="7.x"
		$PVSobj.Repository="\\" + $PVSobj.Name + "." + $PVSobj.Domain + "\D$\vDisks"
		$PVSobj.DataCenter="WI"
		# Add PVS object to PVS Server List collection (array)
		$PVSsvrList += $PVSobj
	#** Populate a new PVS Server object with values
	$PVSobj = New-Object PSObject -Property $PVSsvrProperties
		$PVSobj.Name="PVSsrv04"
		$PVSobj.Domain="somedomain.com"
		$PVSobj.Version="7.x"
		$PVSobj.Repository="\\" + $PVSobj.Name + "." + $PVSobj.Domain + "\D$\vDisks"
		$PVSobj.DataCenter="WI"
		# Add PVS object to PVS Server List collection (array)
		$PVSsvrList += $PVSobj
#** Old Environment Values	
	#** Populate a new PVS Server object with values
	$PVSobj = New-Object PSObject -Property $PVSsvrProperties
		$PVSobj.Name="PVSsrv601"
		$PVSobj.Domain="somedomain.com"
		$PVSobj.Version="6.x"
		$PVSobj.Repository="\\" + $PVSobj.Name + "." + $PVSobj.Domain + "\D$\vDisks"
		$PVSobj.DataCenter="CA"
		# Add PVS object to PVS Server List collection (array)
		$PVSsvrList += $PVSobj
	#** Populate a new PVS Server object with values
	$PVSobj = New-Object PSObject -Property $PVSsvrProperties
		$PVSobj.Name="PVSsrv602"
		$PVSobj.Domain="somedomain.com"
		$PVSobj.Version="6.x"
		$PVSobj.Repository="\\" + $PVSobj.Name + "." + $PVSobj.Domain + "\D$\vDisks"
		$PVSobj.DataCenter="CA"
		# Add PVS object to PVS Server List collection (array)
		$PVSsvrList += $PVSobj
	#** Populate a new PVS Server object with values
	$PVSobj = New-Object PSObject -Property $PVSsvrProperties
		$PVSobj.Name="PVSsrv603"
		$PVSobj.Domain="somedomain.com"
		$PVSobj.Version="6.x"
		$PVSobj.Repository="\\" + $PVSobj.Name + "." + $PVSobj.Domain + "\D$\vDisks"
		$PVSobj.DataCenter="WI"
		# Add PVS object to PVS Server List collection (array)
		$PVSsvrList += $PVSobj
	#** Populate a new PVS Server object with values
	$PVSobj = New-Object PSObject -Property $PVSsvrProperties
		$PVSobj.Name="PVSsrv604"
		$PVSobj.Domain="somedomain.com"
		$PVSobj.Version="6.x"
		$PVSobj.Repository="\\" + $PVSobj.Name + "." + $PVSobj.Domain + "\D$\vDisks"
		$PVSobj.DataCenter="WI"
		# Add PVS object to PVS Server List collection (array)
		$PVSsvrList += $PVSobj

# ======================================================================
# -- F U N C T I O N S
# ======================================================================

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

Function Get-PvsEnvironment () {
	cls
	$PVSversions = $PVSsvrList | Select Version | Sort-Object Version -Unique
	
	Write-Prompt "Select the PVS Enviroment to work with"
	Write-Prompt " "
	$Count = 0
	$Choice_Num = ""
	foreach ($PVSversion in $PVSversions) {
		#Write-Prompt "$Count - $PVSversion.Version Environment"
		Write-Host "$Count - " $PVSversion.Version "Environment"
		foreach ($PVSsvr in $PVSsvrList) {
			if ($PVSsvr.Version -eq $PVSversion.Version) {
				Write-Host "        * " $PVSsvr.Name
			} # End if $PVSsvr.Version
		} # END foreach $PVSsvr
		$Count = $Count + 1
	} # END foreach $PVSversion
	Write-Prompt " "
	Write-Prompt "Please enter the NUMBER of the choice to use"
	Write-Prompt " "
	$Choice_Num = Read-Host 
	$PVSenvChoice = $PVSversions[$Choice_Num].Version
	
	$SelectedPVSsvrs = $PVSsvrList | where {$_.Version -eq $PVSenvChoice } | Sort-Object Name
	
	Return $SelectedPVSsvrs
		
} # END Get-PvsEnvironment

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
		$SourceSvr
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
	
	# ** Looking up the PVS Server object by server name
	$SrcSvr = $PVSsvrList | where {$_.Name -eq $SourceSvr}
	$SrcRepository = $SrcSvr.Repository
		
	foreach ($PVSServer in $PVSServers) {
		if ($PVSServer.Name -ne $SourceSvr.Name) {
			$DestRepository = $PVSServer.Repository
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
# ** Following line results in prompting for each server name
#$PVSServers = Get-ListOfItemsFromUser "PVS Server" 
# ** Instead prompting for environment, which will contain all servers
$PVSServers = Get-PvsEnvironment

cls
Write-Prompt "Gathering list of vDisks containing ($vDiskName)..."
foreach ($PVSServer in $PVSServers) {
	#$Files = dir \\$PVSServer\$vDiskShare\$vDiskName
	$SearchPath = $PVSServer.Repository + "\" + $vDiskName 
	$Files = dir $SearchPath
	# ** If new vDisk, result of $Files might be empty for most servers
	if ($Files) {
		foreach ($File in $Files) {
			# -- Create the new object for a File
			$objFile = New-Object System.Object
			$objFile | Add-Member -type NoteProperty -Name PVSserver -Value $PVSServer.Name
			$objFile | Add-Member -type NoteProperty -Name FileName -Value $File.Name
			$objFile | Add-Member -type NoteProperty -Name FileSize -Value $File.Length
			$objFile | Add-Member -type NoteProperty -Name FileModDate -Value $File.LastWriteTime
			$objFile | Add-Member -type NoteProperty -Name Newest -Value $null
			# -- Add File Object into Array
			$colFiles += $objFile
		} # End foreach File
	} # END if $Files
	else {
		Write-Host "No vDisk Files on" $PVSServer.Name "contain (" $vDiskName ")" -BackgroundColor Yellow -ForegroundColor Black
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

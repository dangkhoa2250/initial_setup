Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

function Write-Start {
	param ($msg)
	Write-Host (">> " + $msg) -ForegroundColor Green
}

function Write-Done {
	Write-Host "Done" -ForegroundColor Blue;
	Write-Host
}

Write-Start -msg "Configuring nvim"
	$DestinationPath = "~\AppData\Local\nvim"
	If (-not (Test-Path $DestinationPath)){
		New-Item -ItemType Directory -Path $DestinationPath
	}
	Copy-Item ".\neovim\.config\nvim\*" -Destination $DestinationPath -Force
	iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
    ni "$(@($env:XDG_DATA_HOME, $env:LOCALAPPDATA)[$null -eq $env:XDG_DATA_HOME])/nvim-data/site/autoload/plug.vim" -Force
	nvim -E -s -u "$($env:LOCALAPPDATA)\nvim\init.vim" +PlugInstall +PlugUpdate +q
	################################################################################################################
	#-E: option tells nvimto run in Exmode, which is a mode that allows you to run Ex command
	#-s: tells nvim to operate in slient mode
	# -u:  -u "$($env:LOCALAPPDATA)\nvim\init.vim": This part specifies the initialization file
	# that Neovim should use. It's using the -u option to specify a custom configuration file. 
	# In this case, it's using a Windows environment variable, $env:LOCALAPPDATA 
	################################################################################################################
Write-Done

# Define the registry path and value name
$regPath = "HKLM:\System\CurrentControlSet\Control\Keyboard Layout"
$regValueName = "Scancode Map"

# Define the binary data for the Caps Lock to Ctrl remapping
$binaryData = [byte[]](0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x1D, 0x00, 0x3A, 0x00, 0x3A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)

# Check if the Registry path exists
if (Test-Path $regPath) {
    # Create or set the Scancode Map value in the Registry
    Set-ItemProperty -Path $regPath -Name $regValueName -Value $binaryData

    # Notify the user
    Write-Host "Caps Lock key has been remapped to Control. Please restart your computer for the changes to take effect."
	$restartChoice = Read-Host "Do you want to restart your computer now? (Y/N)"
    if ($restartChoice -eq 'Y' -or $restartChoice -eq 'y') {
        Write-Host "Restarting your computer..."
        Restart-Computer -Force
    } else {
        Write-Host "You can manually restart your computer to apply the changes."
    }
} else {
    Write-Host "The Registry path does not exist. Make sure you have the necessary permissions."
}
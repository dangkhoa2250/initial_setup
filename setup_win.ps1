$confirmation = Read-Host "Do you want to install Office365 ? (Type 'Y' for Yes or 'N' for No)"
if ($confirmation -eq 'Y' -or $confirmation -eq 'y') {
	Write-Host "Installing Office365..."
	# Define download and configuration paths
	$downloadPath = "C:\Users\dangk\OneDrive\Desktop"
	$odtFolder = "ODTInstaller"
	$downloadUrl = "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_16626-20148.exe"
	$odtInstallerPath = Join-Path -Path $downloadPath -ChildPath $odtFolder
	$odtInstallerFile = Join-Path -Path $odtInstallerPath -ChildPath "ODTSetup.exe"

	# Create the folder if it doesn't exist
	if (-not (Test-Path -Path $odtInstallerPath -PathType Container)) {
		New-Item -Path $odtInstallerPath -ItemType Directory -Force
	}

	# Download the ODT installer
	if (-not (Test-Path -Path $odtInstallerFile -PathType Leaf)) {
		Invoke-WebRequest -Uri $downloadUrl -OutFile $odtInstallerFile
	}

	# Run the installation
	Start-Process C:\Users\dangk\OneDrive\Desktop\ODTInstaller\ODTSetup.exe -wait
	Start-Job -ScriptBlock {
		C:\Users\dangk\OneDrive\Desktop\ODTInstaller\setup.exe /download  C:\Users\dangk\OneDrive\Desktop\ODTInstaller\configuration-Office365-x64.xml 
	}
	C:\Users\dangk\OneDrive\Desktop\ODTInstaller\setup.exe /configure  C:\Users\dangk\OneDrive\Desktop\ODTInstaller\configuration-Office365-x64.xml 
	# Remove the downloaded ODT installer (optional)
	Remove-Item C:\Users\dangk\OneDrive\Desktop\ODTInstaller -Recurse 
	Remove-Item C:\Users\dangk\OneDrive\Desktop\Office -Recurse 
	Write-Host "Office 365 installation completed and ODT installer deleted (if removal is uncommented)."
	}

# Run this command if no execution policy error: Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
# Utility functions
function Write-Start {
	param ($msg)
	Write-Host (">> " + $msg) -ForegroundColor Green
}

function Write-Done {
	Write-Host "Done" -ForegroundColor Blue;
	Write-Host
}

# Start
# Modify a Registry value
Start-Process -Wait powershell -verb runas -ArgumentList "Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0"
Write-Start -msg "Install Scoop..."
if (Get-Command scoop -ErrorAction SilentlyContinue) {
	Write-Warning "Scoop already installed"
} else {
	# Set the execution policy for the current user
	Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
	# Download and execute the Scoop installer script
	Invoke-WebRequest get.scoop.sh | Invoke-Expression
}
Write-Done

Write-Start -msg "Install Chocolatey"
	Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
Write-Done
Write-Start -msg "Install Unikey"
	choco install unikey

Write-Start -msg "Initializig Scoop..."
	scoop install git
	scoop bucket add extras
	scoop bucket add nerd-fonts
	scoop bucket add java
	scoop update
Write-Done

Write-Start -msg "Installing Scoop's package"
	scoop install brave googlechrome
	scoop install neovim vscode gcc miniconda3 nodejs python conemu
	scoop install spotify
	scoop install 
Write-Done

Write-Start -msg "Installing Powertoys"
	winget install Microsoft.PowerToys -s winget
Write-Done

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

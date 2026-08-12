param (
    [Parameter(Mandatory=$false)]
    [string]$VMName = "VM Name",

    [Parameter(Mandatory=$false)]
    # UPDATE THIS PATH to where you downloaded your ISO
    [string]$ISOPath = "PATH TO ISO File",

    [Parameter(Mandatory=$false)]
    # The Virtual Switch name (Run 'Get-VMSwitch' to see available switches)
    [string]$SwitchName = "Default Switch",

    [Parameter(Mandatory=$false)]
    [int64]$MemoryGB = 4,

    [Parameter(Mandatory=$false)]
    [int]$CPUCount = 2,

    [Parameter(Mandatory=$false)]
    [int64]$DiskSizeGB = 40
)

# --- 1. Validation Checks ---

# Check if running as Admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Please run PowerShell as Administrator."
    exit
}

# Check if Hyper-V module exists
if (-not (Get-Module -ListAvailable -Name Hyper-V)) {
    Write-Error "Hyper-V PowerShell module is not installed. Please enable Hyper-V feature."
    exit
}

# Check if ISO exists
if (-not (Test-Path $ISOPath)) {
    Write-Error "ISO file not found at: $ISOPath"
    exit
}

# Check if Virtual Switch exists
$VMSwitch = Get-VMSwitch -Name $SwitchName -ErrorAction SilentlyContinue
if (-not $VMSwitch) {
    Write-Error "Virtual Switch '$SwitchName' not found. Please create one in Hyper-V Virtual Switch Manager."
    exit
}

# --- 2. VM Creation ---

Write-Host "Creating VM: $VMName..." -ForegroundColor Cyan

# Define VM Path (Uses default Hyper-V path if not specified)
$VMPath = (Get-VMHost).VirtualMachinePath

# Create the VM (Gen 2 is required for modern Linux/Ubuntu)
# We create a small dummy disk initially, then resize it, or create it directly with size.
$NewVMDiskPath = Join-Path -Path $VMPath -ChildPath "$VMName\Virtual Disks\$VMName.vhdx"

New-VM `
    -Name $VMName `
    -Generation 2 `
    -MemoryStartupBytes ($MemoryGB * 1GB) `
    -BootDevice VHD `
    -Path $VMPath `
    -NewVHDPath $NewVMDiskPath `
    -NewVHDSizeBytes ($DiskSizeGB * 1GB) `
    -SwitchName $SwitchName `
    -ErrorAction Stop

Write-Host "VM Created successfully." -ForegroundColor Green

# --- 3. Configuration ---

# Set Processor Count
Set-VMProcessor -VMName $VMName -Count $CPUCount

# Disable Dynamic Memory (Generally recommended for Linux for stability, though optional)
Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $false

# Configure Secure Boot
# Ubuntu supports Secure Boot. If using an older/non-standard ISO, set to Off.
Set-VMFirmware -VMName $VMName -SecureBootTemplateName "MicrosoftUEFICertificateAuthority"
Set-VMFirmware -VMName $VMName -EnableSecureBoot $true

# Mount ISO
Add-VMDvdDrive -VMName $VMName -Path $ISOPath

# Set Boot Order to DVD first
$DVDDrive = Get-VMDvdDrive -VMName $VMName
$BootOrder = $DVDDrive, (Get-VMHardDiskDrive -VMName $VMName)
Set-VMFirmware -VMName $VMName -BootOrder $BootOrder

# Enable Enhanced Session Mode (Allows Copy/Paste and easier screen resolution)
Set-VM -VMName $VMName -EnhancedSessionTransportType HvSocket

# --- 4. Finish ---

Write-Host "Configuration complete." -ForegroundColor Cyan
Write-Host "Starting VM: $VMName..." -ForegroundColor Cyan

Start-VM -Name $VMName

Write-Host "---------------------------------------------------"
Write-Host "VM is running." -ForegroundColor Green
Write-Host "Connect to the VM to complete the installation."
Write-Host "You can connect using Hyper-V Manager or run:"
Write-Host "vmconnect.exe localhost $VMName"
Write-Host "---------------------------------------------------"
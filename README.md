# Hyper-V-VM-Creation

A PowerShell script for quickly creating and configuring a virtual machine using Microsoft Hyper-V.

The script handles the initial VM setup, including memory, CPU, virtual disk, networking, firmware, ISO mounting, boot order, and starting the VM.

Requirements
Windows with Hyper-V enabled
PowerShell
Administrator privileges
An operating system ISO
A Hyper-V Virtual Switch

The script performs validation checks before creating the VM.

Usage

Run PowerShell as Administrator and run the script with your desired settings.

Example:

.\New-VM.ps1 `
    -VMName "MyVM" `
    -ISOPath "C:\ISO\installer.iso" `
    -SwitchName "Default Switch" `
    -MemoryGB 4 `
    -CPUCount 2 `
    -DiskSizeGB 40
Parameters
Parameter	Default	Description
VMName	VM Name	Name of the virtual machine
ISOPath	PATH TO ISO File	Path to the operating system ISO
SwitchName	Default Switch	Hyper-V virtual switch to connect the VM to
MemoryGB	4	Startup memory allocated to the VM in GB
CPUCount	2	Number of virtual processors
DiskSizeGB	40	Size of the virtual hard disk in GB

The parameters can be changed to suit the VM you want to create.

Finding Virtual Switches

To see the Virtual Switches available on your system, run:

Get-VMSwitch

Then provide the desired switch name using -SwitchName.

What It Does

The script:

Checks that PowerShell is running as Administrator.
Checks that the Hyper-V PowerShell module is available.
Verifies that the specified ISO exists.
Verifies that the specified Virtual Switch exists.
Creates a Generation 2 virtual machine.
Creates a virtual hard disk with the specified capacity.
Configures the VM's CPU and memory.
Disables Dynamic Memory.
Configures Secure Boot.
Mounts the specified ISO.
Sets the ISO/DVD drive as the first boot device.
Configures Enhanced Session Mode transport.
Starts the virtual machine.
Example Configurations

A smaller VM:

.\New-VM.ps1 `
    -VMName "TestVM" `
    -ISOPath "C:\ISO\installer.iso" `
    -MemoryGB 2 `
    -CPUCount 1 `
    -DiskSizeGB 20

A larger VM:

.\New-VM.ps1 `
    -VMName "DevelopmentVM" `
    -ISOPath "D:\ISOs\installer.iso" `
    -SwitchName "Default Switch" `
    -MemoryGB 8 `
    -CPUCount 4 `
    -DiskSizeGB 100
Connecting to the VM

Once the script has finished, you can connect to the VM using Hyper-V Manager or:

vmconnect.exe localhost "MyVM"

Replace "MyVM" with the name of your virtual machine.

Notes

The script is intended to automate the initial creation and configuration of a Hyper-V VM. Operating system installation is completed after the VM starts.

Make sure the VM name does not already exist in Hyper-V before running the script.

The default parameter values are examples and should be changed to match your setup.

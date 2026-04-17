<#
.SYNOPSIS
    Curated PowerShell command examples for enabling and validating OpenSSH on Windows.

.DESCRIPTION
    This script is a GitHub-ready, copy/paste-friendly collection of PowerShell and terminal command
    examples based on the accompanying video walkthrough for enabling OpenSSH on:
      - Windows Server 2025
      - Windows Server 2022
      - Windows Server 2019
      - Windows Server Core
      - Windows 11

    It demonstrates how to:
      - Check current OpenSSH capability state
      - Install OpenSSH Server where needed
      - Install OpenSSH Server offline using a Features on Demand source
      - Enable and start the sshd service
      - Validate listening on TCP port 22
      - Inspect and test sshd_config
      - Create and use an OpenSSH Users group with AllowGroups
      - Inspect OpenSSH firewall rules and scope access by profile / remote address
      - Test SSH, SCP, and PowerShell remoting over SSH

    These are example commands, not a single end-to-end automation script. Use only the sections you need.

.NOTES
    Author      : Darien Hawkins
    Channel     : https://www.youtube.com/@darienstips9409
    Repository  : https://github.com/DariensTips
    Requires    : Windows PowerShell 5.1 or PowerShell 7+ (run elevated where required)
    Tested On   : Windows Server 2019/2022/2025, Windows Server Core, Windows 11

.DISCLAIMER
    Use only on systems you own or are authorized to manage. Before enabling SSH access,
    validate firewall scope, authentication method, local group membership, and your
    organization's security requirements. Test in a lab first whenever possible.
#>

# ============================================================================
# 01 - Check OpenSSH capability state
# ============================================================================

# Shows whether OpenSSH Client and Server are present on the current running system.
Get-WindowsCapability -Online -Name *ssh*


# ============================================================================
# 02 - Install OpenSSH Server (Windows Server 2019 / 2022 / Windows 11)
# ============================================================================

# Installs the OpenSSH Server capability on the current running system.
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0


# ============================================================================
# 03 - Install OpenSSH Server offline using a Features on Demand source
# ============================================================================

# Example source path for a mounted Languages and Optional Features ISO.
$lofSource = 'D:\LanguagesAndOptionalFeatures'

# Installs OpenSSH Server from the specified local source and avoids contacting Windows Update.
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 -Source $lofSource -LimitAccess


# ============================================================================
# 04 - Check, enable, and start the OpenSSH Server service
# ============================================================================

# Review current service state and startup type.
Get-Service -Name sshd | Select-Object Status, Name, DisplayName, StartType

# Set the sshd service to start automatically.
Set-Service -Name sshd -StartupType Automatic

# Start the sshd service.
Start-Service -Name sshd

# Re-check state after enabling the service.
Get-Service -Name sshd | Select-Object Status, Name, DisplayName, StartType


# ============================================================================
# 05 - Verify SSH is listening on TCP port 22
# ============================================================================

# Modern PowerShell method.
Get-NetTCPConnection -State Listen -LocalPort 22

# Legacy validation method.
netstat -ano | findstr -i LISTENING | findstr :22


# ============================================================================
# 06 - Locate and inspect the OpenSSH configuration directory
# ============================================================================

# Change to the OpenSSH configuration directory.
Set-Location C:\ProgramData\ssh

# List contents, including host keys and sshd_config.
Get-ChildItem

# Open the SSH daemon configuration file in Visual Studio Code.
# Replace with another editor if preferred, such as notepad.exe.
code C:\ProgramData\ssh\sshd_config

# List built-in local groups.
Get-LocalGroup


# ============================================================================
# 07 - Create an OpenSSH Users group and restrict access with AllowGroups
# ============================================================================

# Create a local group for users allowed to connect through SSH.
New-LocalGroup -Name 'OpenSSH Users' -Description 'Users allowed to connect via SSH'

# Add the following line to sshd_config under the Subsystem section:
# AllowGroups administrators "openssh users"

# Validate the configuration syntax before restarting the service.
sshd -t

# Restart the SSH daemon service after making configuration changes.
Restart-Service -Name sshd

# Optional: confirm that only expected users/groups are permitted to authenticate.
# Members should typically be in either Administrators or OpenSSH Users, depending on your policy.


# ============================================================================
# 08 - Inspect the OpenSSH binaries folder
# ============================================================================

Get-ChildItem C:\Windows\System32\OpenSSH\


# ============================================================================
# 09 - Inspect Windows Firewall network profile and OpenSSH rules
# ============================================================================

# Identify the active network category/profile.
Get-NetConnectionProfile

# Review OpenSSH-related firewall rules.
Get-NetFirewallRule -Name OpenSSH-Server*
Get-NetFirewallRule -Name OpenSSH*

# Restrict the OpenSSH Server firewall rule to Domain and Private profiles.
Set-NetFirewallRule -Name OpenSSH-Server-In-TCP -Profile Domain, Private

# Review current address filter settings for the OpenSSH Server rule.
Get-NetFirewallRule -Name OpenSSH-Server-In-TCP | Get-NetFirewallAddressFilter

# Example: limit remote SSH access to a specific IP address and the local subnet.
Get-NetFirewallRule -Name OpenSSH* |
    Get-NetFirewallAddressFilter |
    Set-NetFirewallAddressFilter -RemoteAddress 12.3.4.5, LocalSubnet


# ============================================================================
# 10 - SSH examples
# ============================================================================

# Connect to a target Windows host over SSH.
ssh professa@sshwinsvr2025

# Example test accounts for validating group-based access.
ssh cando@sshwinsvr2025
ssh cannotdo@sshwinsvr2025

# After connecting, you can launch Windows PowerShell or PowerShell 7 if installed:
# powershell
# pwsh
# Get-Host
# sconfig


# ============================================================================
# 11 - SCP examples
# ============================================================================

# From a Windows terminal, both forward slashes and backslashes generally work in the Windows path.
scp professa@sshwinsvr2025:c:/windows/system32/wpr.config.xml .
scp professa@sshwinsvr2025:c:\windows\system32\wpr.config.xml .

# Linux note:
# When copying from Linux to a Windows target path, forward slashes are typically safer because
# Linux shells interpret backslashes as escape characters.


# ============================================================================
# 12 - PowerShell remoting over SSH examples
# ============================================================================

# Start an interactive PowerShell session over SSH using -HostName.
Enter-PSSession -HostName professa@sshwinsvr2025

# Alternate syntax using -SSHTransport.
Enter-PSSession professa@sshwinsvr2025 -SSHTransport

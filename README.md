
How to Enable OpenSSH on Windows Server 2019, 2022, 2025 &amp; Windows 11 (Step-by-Step)
# Enable OpenSSH on Windows - PowerShell Examples

This repository contains a **GitHub-ready PowerShell command reference** for enabling and validating **OpenSSH on Windows**.

It is designed as a **copy/paste-friendly companion** to the video walkthrough and covers:

- Windows Server 2025
- Windows Server 2022
- Windows Server 2019
- Windows Server Core
- Windows 11

## What is included

- `enable-openssh-windows-examples.ps1`
  - Curated command examples for checking OpenSSH state, installing the server feature, enabling `sshd`, validating TCP port 22, editing `sshd_config`, restricting access with `AllowGroups`, reviewing firewall rules, testing SSH/SCP, and using PowerShell remoting over SSH.

## Important notes

- This is **not** intended to be run as one large automation script from top to bottom.
- Each numbered section is **independent** so you can copy only the commands you need.
- Some steps in the video are performed through the **Windows GUI**. This `.ps1` file focuses on the **terminal / PowerShell commands** that support those tasks.
- Run elevated where required.
- Validate access controls, firewall scope, and authentication settings before exposing SSH to other systems.

## Script sections

1. Check OpenSSH capability state
2. Install OpenSSH Server
3. Install OpenSSH Server offline from a Features on Demand source
4. Check, enable, and start the `sshd` service
5. Verify SSH is listening on TCP port 22
6. Locate and inspect the OpenSSH configuration directory
7. Create an `OpenSSH Users` group and restrict access with `AllowGroups`
8. Inspect the OpenSSH binaries folder
9. Inspect Windows Firewall network profile and OpenSSH rules
10. SSH examples
11. SCP examples
12. PowerShell remoting over SSH examples

## Example usage

### Check current OpenSSH capability state

```powershell
Get-WindowsCapability -Online -Name *ssh*
```

### Install OpenSSH Server

```powershell
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
```

### Enable and start the SSH daemon

```powershell
Set-Service -Name sshd -StartupType Automatic
Start-Service -Name sshd
Get-Service -Name sshd | Select-Object Status, Name, DisplayName, StartType
```

### Verify TCP port 22 is listening

```powershell
Get-NetTCPConnection -State Listen -LocalPort 22
netstat -ano | findstr -i LISTENING | findstr :22
```

### Test and restart `sshd` after config changes

```powershell
sshd -t
Restart-Service -Name sshd
```

## Related topics covered in the video

- OpenSSH installation differences across supported Windows versions
- Server Core vs Desktop Experience considerations
- `sshd_config` basics
- Restricting SSH access with local groups and `AllowGroups`
- Firewall profile and remote-address scoping
- SSH, SCP, and Enter-PSSession over SSH

## Disclaimer

These examples are for **educational and authorized administrative use only**. Always verify firewall rules, authentication settings, local group membership, and security policy requirements before enabling SSH on a Windows system. Test in a lab first whenever possible.

## Author

**Darien Hawkins**  
YouTube: https://www.youtube.com/@darienstips9409  
GitHub: https://github.com/DariensTips

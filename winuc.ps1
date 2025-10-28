#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Windows 11 Ultimate Configurator
    PowerShell GUI for Windows 11 system enhancement and requirements bypass.

.DESCRIPTION
    This tool provides a GUI interface for configuring Windows 11 settings,
    bypassing hardware requirements, and generating unattended installation files.

.NOTES
    Author: SilentGlasses
    Version: 1.1.0
    Requires: PowerShell 5.1+, Administrator privileges
#>

try {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    Write-Host "Assemblies loaded successfully" -ForegroundColor Green
} catch {
    Write-Error "Failed to load required assemblies: $_"
    Read-Host "Press Enter to exit"
    exit 1
}

# Initialize global variables with proper null handling
#===============================================================================
$Global:isDarkMode = $false
$Global:colors = @{}
$Global:bypassCheckboxes = @()
$Global:enhancementCheckboxes = @()

# Initialize default colors immediately
#===============================================================================
$Global:colors = @{
    Background = [System.Drawing.Color]::FromArgb(243, 243, 243)
    Surface = [System.Drawing.Color]::White
    SurfaceHover = [System.Drawing.Color]::FromArgb(245, 245, 245)
    Primary = [System.Drawing.Color]::FromArgb(0, 120, 212)
    PrimaryHover = [System.Drawing.Color]::FromArgb(16, 110, 190)
    Text = [System.Drawing.Color]::FromArgb(32, 32, 32)
    TextSecondary = [System.Drawing.Color]::FromArgb(96, 96, 96)
    Border = [System.Drawing.Color]::FromArgb(200, 200, 200)
    Success = [System.Drawing.Color]::FromArgb(16, 124, 16)
    Warning = [System.Drawing.Color]::FromArgb(157, 93, 0)
}

function Get-SafeColor {
    <#
    .SYNOPSIS
        Safely retrieves a color from the global colors hashtable
    #>
    [OutputType([System.Drawing.Color])]
    param(
        [Parameter(Mandatory = $false)]
        [string]$ColorName,

        [System.Drawing.Color]$DefaultColor = [System.Drawing.Color]::Black
    )

    # Handle null, empty, or whitespace-only color names
    if ([string]::IsNullOrWhiteSpace($ColorName)) {
        Write-Verbose "Empty or null ColorName provided, using default color"
        return $DefaultColor
    }

    # Check if global colors hashtable exists and contains the requested color
    if ($null -ne $Global:colors -and $Global:colors.ContainsKey($ColorName)) {
        return $Global:colors[$ColorName]
    }

    Write-Verbose "Color '$ColorName' not found in global colors, using default color"
    return $DefaultColor
}

function Get-WindowsTheme {
    <#
    .SYNOPSIS
        Detects Windows theme (light/dark mode)
    #>
    [OutputType([bool])]
    param()

    try {
        $regPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
        if (Test-Path -Path $regPath -ErrorAction SilentlyContinue) {
            $property = Get-ItemProperty -Path $regPath -Name 'AppsUseLightTheme' -ErrorAction SilentlyContinue
            if ($null -ne $property -and $null -ne $property.AppsUseLightTheme) {
                return ($property.AppsUseLightTheme -eq 0)
            }
        }
        return $false
    } catch {
        Write-Verbose "Theme detection failed: $_"
        return $false
    }
}

function Set-ColorScheme {
    <#
    .SYNOPSIS
        Sets the color scheme based on Windows theme
    #>
    [CmdletBinding()]
    param()

    try {
        $Global:isDarkMode = Get-WindowsTheme

        if ($Global:isDarkMode) {
            $Global:colors.Background = [System.Drawing.Color]::FromArgb(32, 32, 32)
            $Global:colors.Surface = [System.Drawing.Color]::FromArgb(45, 45, 45)
            $Global:colors.Text = [System.Drawing.Color]::White
            $Global:colors.TextSecondary = [System.Drawing.Color]::FromArgb(200, 200, 200)
            $Global:colors.Border = [System.Drawing.Color]::FromArgb(70, 70, 70)
        } else {
            $Global:colors.Background = [System.Drawing.Color]::FromArgb(243, 243, 243)
            $Global:colors.Surface = [System.Drawing.Color]::White
            $Global:colors.Text = [System.Drawing.Color]::FromArgb(32, 32, 32)
            $Global:colors.TextSecondary = [System.Drawing.Color]::FromArgb(96, 96, 96)
            $Global:colors.Border = [System.Drawing.Color]::FromArgb(200, 200, 200)
        }
    } catch {
        Write-Warning "Color scheme setup failed: $_"
    }
}

# Enhancement options
#===============================================================================
$Global:enhancementOptions = @{
    #===========================================================================
    #              BYPASS OPTIONS
    #===========================================================================
    bypass = @(
        @{
            Name = 'Bypass TPM 2.0 Requirement'
            Description = 'Allows Windows 11 installation on systems without TPM 2.0 chip'
            Category = 'bypass'
            RegistryPath = 'HKLM:\SYSTEM\Setup\LabConfig'
            RegistryName = 'BypassTPMCheck'
            RegistryValue = 1
        },
        @{
            Name = 'Bypass Secure Boot Requirement'
            Description = 'Disables Secure Boot requirement for Windows 11 installation'
            Category = 'bypass'
            RegistryPath = 'HKLM:\SYSTEM\Setup\LabConfig'
            RegistryName = 'BypassSecureBootCheck'
            RegistryValue = 1
        },
        @{
            Name = 'Bypass RAM Requirement'
            Description = 'Allows installation on systems with less than 4GB RAM'
            Category = 'bypass'
            RegistryPath = 'HKLM:\SYSTEM\Setup\LabConfig'
            RegistryName = 'BypassRAMCheck'
            RegistryValue = 1
        },
        @{
            Name = 'Bypass CPU Requirement'
            Description = 'Bypasses CPU compatibility check for unsupported processors'
            Category = 'bypass'
            RegistryPath = 'HKLM:\SYSTEM\Setup\LabConfig'
            RegistryName = 'BypassCPUCheck'
            RegistryValue = 1
        },
        @{
            Name = 'Bypass Storage Requirement'
            Description = 'Bypasses the 64GB minimum storage requirement for Windows 11'
            Category = 'bypass'
            RegistryPath = 'HKLM:\SYSTEM\Setup\LabConfig'
            RegistryName = 'BypassStorageCheck'
            RegistryValue = 1
        },
        @{
            Name = 'Skip OOBE Network Connection'
            Description = 'Skips the network connection screen during Out-of-Box-Experience'
            Category = 'bypass'
            RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE'
            RegistryName = 'BypassNRO'
            RegistryValue = 1
        },
        @{
            Name = 'Install Without Microsoft Account'
            Description = 'Enables the option to install Windows 11 without requiring a Microsoft account'
            Category = 'bypass'
            RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE'
            RegistryName = 'BypassMSAOOBE'
            RegistryValue = 1
        }
    )
    #===========================================================================
    #              PRIVACY OPTIONS
    #===========================================================================
    privacy = @(
        @{
            Name = 'Disable Telemetry'
            Description = 'Disables Windows telemetry and diagnostic data collection'
            Category = 'privacy'
            RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'
            RegistryName = 'AllowTelemetry'
            RegistryValue = 0
        },
        @{
            Name = 'Disable Cortana'
            Description = 'Disables Cortana voice assistant and data collection'
            Category = 'privacy'
            RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'
            RegistryName = 'AllowCortana'
            RegistryValue = 0
        },
        @{
            Name = 'Disable Location Services'
            Description = 'Disables location tracking for all applications'
            Category = 'privacy'
            RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors'
            RegistryName = 'DisableLocation'
            RegistryValue = 1
        },
        @{
            Name = 'Disable Advertising ID'
            Description = 'Prevents creation of advertising ID for targeted ads'
            Category = 'privacy'
            RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo'
            RegistryName = 'DisabledByGroupPolicy'
            RegistryValue = 1
        },
        @{
            Name = 'Disable Feedback'
            Description = 'Disables Windows feedback requests and notifications'
            Category = 'privacy'
            RegistryPath = 'HKCU:\SOFTWARE\Microsoft\Siuf\Rules'
            RegistryName = 'NumberOfSIUFInPeriod'
            RegistryValue = 0
        },
        @{
            Name = 'Disable Activity History'
            Description = 'Disables activity history collection for Microsoft Timeline'
            Category = 'privacy'
            RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
            RegistryName = 'EnableActivityFeed'
            RegistryValue = 0
        },
        @{
            Name = 'Block Apps from Accessing Camera'
            Description = 'Prevents apps from accessing your camera'
            Category = 'privacy'
            RegistryPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam'
            RegistryName = 'Value'
            RegistryValue = 'Deny'
        },
        @{
            Name = 'Block Apps from Accessing Microphone'
            Description = 'Prevents apps from accessing your microphone'
            Category = 'privacy'
            RegistryPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone'
            RegistryName = 'Value'
            RegistryValue = 'Deny'
        },
        @{
            Name = 'Disable Windows Search Web Results'
            Description = 'Prevents Windows Search from showing web results'
            Category = 'privacy'
            RegistryPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search'
            RegistryName = 'BingSearchEnabled'
            RegistryValue = 0
        },
        @{
            Name = 'Disable Clipboard History'
            Description = 'Disables clipboard history and cloud sync'
            Category = 'privacy'
            RegistryPath = 'HKCU:\SOFTWARE\Microsoft\Clipboard'
            RegistryName = 'EnableClipboardHistory'
            RegistryValue = 0
        }
    )
    #===========================================================================
    #              SECURITY OPTIONS
    #===========================================================================
    security = @(
        @{
            Name = 'Enable Windows Defender'
            Description = 'Ensures Windows Defender real-time protection is enabled'
            Category = 'security'
            RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection'
            RegistryName = 'DisableRealtimeMonitoring'
            RegistryValue = 0
        },
        @{
            Name = 'Enable UAC'
            Description = 'Enables User Account Control for enhanced security'
            Category = 'security'
            RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
            RegistryName = 'EnableLUA'
            RegistryValue = 1
        },
        @{
            Name = 'Enable Windows Firewall'
            Description = 'Ensures Windows Firewall is enabled for all profiles'
            Category = 'security'
            RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile'
            RegistryName = 'EnableFirewall'
            RegistryValue = 1
        },
        @{
            Name = 'Disable AutoRun'
            Description = 'Prevents automatic execution of programs from removable media'
            Category = 'security'
            RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'
            RegistryName = 'NoDriveTypeAutoRun'
            RegistryValue = 255
        },
        @{
            Name = 'Enable Secure Desktop for UAC'
            Description = 'Displays UAC prompts on the secure desktop'
            Category = 'security'
            RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
            RegistryName = 'PromptOnSecureDesktop'
            RegistryValue = 1
        },
        @{
            Name = 'Enable SmartScreen'
            Description = 'Enables SmartScreen protection for Edge and Store apps'
            Category = 'security'
            RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
            RegistryName = 'EnableSmartScreen'
            RegistryValue = 1
        },
        @{
            Name = 'Disable Remote Assistance'
            Description = 'Prevents others from connecting via Remote Assistance'
            Category = 'security'
            RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance'
            RegistryName = 'fAllowToGetHelp'
            RegistryValue = 0
        },
        @{
            Name = 'Block Potentially Unwanted Apps'
            Description = 'Blocks potentially unwanted applications'
            Category = 'security'
            RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender'
            RegistryName = 'PUAProtection'
            RegistryValue = 1
        }
    )
    #===========================================================================
    #              PERFORMANCE OPTIONS
    #===========================================================================
    performance = @(
        @{
            Name = 'Disable Visual Effects'
            Description = 'Disables unnecessary visual effects to improve performance'
            Category = 'performance'
            RegistryPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects'
            RegistryName = 'VisualFXSetting'
            RegistryValue = 2
        },
        @{
            Name = 'Reduce Startup Delay'
            Description = 'Reduces delay when starting programs with Windows'
            Category = 'performance'
            RegistryPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
            RegistryName = 'StartupDelayInMSec'
            RegistryValue = 0
        },
        @{
            Name = 'Optimize CPU Priority'
            Description = 'Adjusts system responsiveness to prioritize foreground apps'
            Category = 'performance'
            RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl'
            RegistryName = 'Win32PrioritySeparation'
            RegistryValue = 38
        },
        @{
            Name = 'Disable Search Indexing'
            Description = 'Disables background indexing of files to reduce disk usage'
            Category = 'performance'
            RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'
            RegistryName = 'PreventIndexingLowDiskSpaceMB'
            RegistryValue = 2147483647
        },
        @{
            Name = 'Optimize Memory Management'
            Description = 'Disables Superfetch/Prefetch for better SSD performance'
            Category = 'performance'
            RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'
            RegistryName = 'EnableSuperfetch'
            RegistryValue = 0
        },
        @{
            Name = 'Disable Menu Show Delay'
            Description = 'Removes delay when showing right-click context menus'
            Category = 'performance'
            RegistryPath = 'HKCU:\Control Panel\Desktop'
            RegistryName = 'MenuShowDelay'
            RegistryValue = '0'
        }
    )
    #===========================================================================
    #              APPEARANCE OPTIONS
    #===========================================================================
    appearance = @(
        @{
            Name = 'Enable Classic Context Menu'
            Description = 'Reverts to the classic right-click context menu'
            Category = 'appearance'
            RegistryPath = 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32'
            RegistryName = '(Default)'
            RegistryValue = ''
        },
        @{
            Name = 'Left-Align Taskbar Icons'
            Description = 'Aligns taskbar icons to the left like Windows 10'
            Category = 'appearance'
            RegistryPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
            RegistryName = 'TaskbarAl'
            RegistryValue = 0
        },
        @{
            Name = 'Show File Extensions'
            Description = 'Shows file extensions for all file types'
            Category = 'appearance'
            RegistryPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
            RegistryName = 'HideFileExt'
            RegistryValue = 0
        },
        @{
            Name = 'Show Hidden Files'
            Description = 'Shows hidden files and folders'
            Category = 'appearance'
            RegistryPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
            RegistryName = 'Hidden'
            RegistryValue = 1
        },
        @{
            Name = 'Hide Task View Button'
            Description = 'Hides the Task View button from the taskbar'
            Category = 'appearance'
            RegistryPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
            RegistryName = 'ShowTaskViewButton'
            RegistryValue = 0
        }
    )
    #===========================================================================
    #              GAMING OPTIONS
    #===========================================================================
    gaming = @(
        @{
            Name = 'Disable Game DVR'
            Description = 'Disables Xbox Game DVR recording for better performance'
            Category = 'gaming'
            RegistryPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR'
            RegistryName = 'AppCaptureEnabled'
            RegistryValue = 0
        },
        @{
            Name = 'Enable Game Mode'
            Description = 'Enables Windows Game Mode for better performance'
            Category = 'gaming'
            RegistryPath = 'HKCU:\SOFTWARE\Microsoft\GameBar'
            RegistryName = 'AllowAutoGameMode'
            RegistryValue = 1
        },
        @{
            Name = 'Disable Windows Game Bar'
            Description = 'Disables the Windows Game Bar overlay'
            Category = 'gaming'
            RegistryPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR'
            RegistryName = 'GameDVR_Enabled'
            RegistryValue = 0
        },
        @{
            Name = 'Disable Fullscreen Optimizations'
            Description = 'Disables fullscreen optimizations for better compatibility'
            Category = 'gaming'
            RegistryPath = 'HKCU:\System\GameConfigStore'
            RegistryName = 'GameDVR_FSEBehaviorMode'
            RegistryValue = 2
        },
        @{
            Name = 'Optimize GPU Scheduling'
            Description = 'Enables hardware-accelerated GPU scheduling'
            Category = 'gaming'
            RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers'
            RegistryName = 'HwSchMode'
            RegistryValue = 2
        },
        @{
            Name = 'Reduce Network Latency'
            Description = 'Reduces network latency for online gaming'
            Category = 'gaming'
            RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters'
            RegistryName = 'TcpAckFrequency'
            RegistryValue = 1
        }
    )
    #===========================================================================
    #              NETWORKING OPTIONS
    #===========================================================================
    network = @(
        @{
            Name = 'Disable Windows Update P2P'
            Description = 'Prevents Windows from sharing updates with other PCs'
            Category = 'network'
            RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config'
            RegistryName = 'DODownloadMode'
            RegistryValue = 0
        },
        @{
            Name = 'Set DNS to Cloudflare'
            Description = 'Sets DNS to Cloudflare (1.1.1.1) for faster browsing'
            Category = 'network'
            RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters'
            RegistryName = 'NameServer'
            RegistryValue = '1.1.1.1,1.0.0.1'
        },
        @{
            Name = 'Disable Network Discovery'
            Description = 'Disables network discovery for enhanced security'
            Category = 'network'
            RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff'
            RegistryName = '(Default)'
            RegistryValue = ''
        },
        @{
            Name = 'Optimize Network Throttling'
            Description = 'Disables network throttling to improve internet speed'
            Category = 'network'
            RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'
            RegistryName = 'NetworkThrottlingIndex'
            RegistryValue = 4294967295
        },
        @{
            Name = 'Enable TCP Window Scaling'
            Description = 'Improves network throughput for high-bandwidth connections'
            Category = 'network'
            RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters'
            RegistryName = 'Tcp1323Opts'
            RegistryValue = 3
        },
        @{
            Name = 'Disable Bandwidth Limiting'
            Description = 'Removes the 20% bandwidth limit reserved for QoS'
            Category = 'network'
            RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched'
            RegistryName = 'NonBestEffortLimit'
            RegistryValue = 0
        }
    )
    #===========================================================================
    #              HOUSECLEANING OPTIONS
    #===========================================================================
    cleanup = @(
        @{
            Name = 'Remove Xbox Apps Auto-Install'
            Description = 'Prevents Xbox-related applications from auto-installing'
            Category = 'cleanup'
            RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'
            RegistryName = 'DisableWindowsConsumerFeatures'
            RegistryValue = 1
        },
        @{
            Name = 'Disable OneDrive'
            Description = 'Disables OneDrive integration and prevents auto-start'
            Category = 'cleanup'
            RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive'
            RegistryName = 'DisableFileSyncNGSC'
            RegistryValue = 1
        },
        @{
            Name = 'Disable Windows Store Auto-Updates'
            Description = 'Prevents Windows Store apps from updating automatically'
            Category = 'cleanup'
            RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore'
            RegistryName = 'AutoDownload'
            RegistryValue = 2
        },
        @{
            Name = 'Clean Temp Files on Startup'
            Description = 'Automatically cleans temporary files when Windows starts'
            Category = 'cleanup'
            RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files'
            RegistryName = 'StateFlags0001'
            RegistryValue = 2
        },
        @{
            Name = 'Disable Hibernation'
            Description = 'Disables hibernation to free up disk space'
            Category = 'cleanup'
            RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power'
            RegistryName = 'HibernateEnabled'
            RegistryValue = 0
        },
        @{
            Name = 'Disable System Restore'
            Description = 'Disables System Restore to free up disk space'
            Category = 'cleanup'
            RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore'
            RegistryName = 'DisableSR'
            RegistryValue = 1
        },
        @{
            Name = 'Disable Error Reporting'
            Description = 'Disables Windows Error Reporting'
            Category = 'cleanup'
            RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting'
            RegistryName = 'Disabled'
            RegistryValue = 1
        }
    )
    #===========================================================================
    #              DEVELOPER OPTIONS
    #===========================================================================
    developer = @(
        @{
            Name = 'Enable Developer Mode'
            Description = 'Enables Windows Developer Mode for app development'
            Category = 'developer'
            RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'
            RegistryName = 'AllowDevelopmentWithoutDevLicense'
            RegistryValue = 1
        },
        @{
            Name = 'Enable Long Path Support'
            Description = 'Enables support for file paths longer than 260 characters'
            Category = 'developer'
            RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem'
            RegistryName = 'LongPathsEnabled'
            RegistryValue = 1
        },
        @{
            Name = 'Show System Files'
            Description = 'Shows protected system files in Windows Explorer'
            Category = 'developer'
            RegistryPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
            RegistryName = 'ShowSuperHidden'
            RegistryValue = 1
        },
        @{
            Name = 'Enable WSL and Sideloading'
            Description = 'Enables Windows Subsystem for Linux and allows sideloading of apps'
            Category = 'developer'
            RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'
            RegistryName = 'AllowAllTrustedApps'
            RegistryValue = 1
        },
        @{
            Name = 'Enable Developer Mode (Unsafe)'
            Description = 'Disables User Account Control for development work - WARNING: Reduces security'
            Category = 'developer'
            RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
            RegistryName = 'EnableLUA'
            RegistryValue = 0
        },
        @{
            Name = 'Enable PowerShell Execution Policy'
            Description = 'Sets PowerShell execution policy to RemoteSigned'
            Category = 'developer'
            RegistryPath = 'HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell'
            RegistryName = 'ExecutionPolicy'
            RegistryValue = 'RemoteSigned'
        },
        @{
            Name = 'Enable WSL Optional Feature'
            Description = 'Enables the Windows Subsystem for Linux optional feature'
            Category = 'developer'
            RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OptionalFeatures'
            RegistryName = 'Microsoft-Windows-Subsystem-Linux'
            RegistryValue = 1
        }
    )
}

function New-ToolTip {
    <#
    .SYNOPSIS
        Creates a tooltip with error handling
    #>
    [OutputType([System.Windows.Forms.ToolTip])]
    param(
        [Parameter(Mandatory)]
        [string]$Text
    )

    try {
        $tooltip = New-Object System.Windows.Forms.ToolTip
        $tooltip.InitialDelay = 500
        $tooltip.ReshowDelay = 100
        $tooltip.AutomaticDelay = 1000
        $tooltip.IsBalloon = $true
        return $tooltip
    } catch {
        Write-Warning "Failed to create tooltip: $_"
        return $null
    }
}

function Get-TextWidth {
    <#
    .SYNOPSIS
        Calculate the width needed for text in a specific font
    #>
    [OutputType([int])]
    param(
        [Parameter(Mandatory)]
        [string]$Text,

        [System.Drawing.Font]$Font = (New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Regular))
    )

    try {
        # Ensure we have valid input
        if ([string]::IsNullOrEmpty($Text)) {
            return 100
        }

        $graphics = [System.Drawing.Graphics]::FromImage((New-Object System.Drawing.Bitmap(1, 1)))
        $size = $graphics.MeasureString($Text, $Font)
        $graphics.Dispose()

        # Ensure we get a numeric value and add padding
        $width = [int][Math]::Ceiling([double]$size.Width)
        return ($width + 20)  # Add 20px padding with explicit parentheses
    } catch {
        Write-Verbose "Error in Get-TextWidth: $_"
        return 100  # Fallback width
    }
}

function New-ModernButton {
    <#
    .SYNOPSIS
        Creates a modern-styled button with proper null safety
    #>
    [OutputType([System.Windows.Forms.Button])]
    param(
        [Parameter(Mandatory)]
        [string]$Text,
        [Parameter(Mandatory)]
        [System.Drawing.Point]$Location,
        [Parameter(Mandatory)]
        [System.Drawing.Size]$Size,
        [string]$BackColor = 'Primary'
    )

    try {
        $button = New-Object System.Windows.Forms.Button
        $button.Text = $Text
        $button.Location = $Location
        $button.Size = $Size
        $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $button.BackColor = Get-SafeColor -ColorName $BackColor -DefaultColor ([System.Drawing.Color]::FromArgb(0, 120, 212))
        $button.ForeColor = [System.Drawing.Color]::White
        $button.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Regular)
        $button.FlatAppearance.BorderSize = 0
        $button.Cursor = [System.Windows.Forms.Cursors]::Hand

        # Store the original color for hover effects
        $originalBackColor = $button.BackColor
        $hoverColor = Get-SafeColor -ColorName 'PrimaryHover' -DefaultColor ([System.Drawing.Color]::FromArgb(16, 110, 190))

        # Safe hover effects
        $button.Add_MouseEnter({
            $this.BackColor = $hoverColor
        }.GetNewClosure())

        $button.Add_MouseLeave({
            $this.BackColor = $originalBackColor
        }.GetNewClosure())

        return $button
    } catch {
        Write-Error "Failed to create button '$Text': $_"
        return $null
    }
}

function New-ModernCheckBox {
    <#
    .SYNOPSIS
        Creates a modern-styled checkbox with tooltip support
    #>
    [OutputType([System.Windows.Forms.CheckBox])]
    param(
        [Parameter(Mandatory)]
        [string]$Text,
        [Parameter(Mandatory)]
        [System.Drawing.Point]$Location,
        [string]$Description = ''
    )

    try {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Text = $Text
        $checkbox.Location = $Location
        $checkbox.Size = New-Object System.Drawing.Size(480, 20)
        $checkbox.BackColor = [System.Drawing.Color]::Transparent
        $checkbox.ForeColor = Get-SafeColor -ColorName 'Text' -DefaultColor ([System.Drawing.Color]::Black)
        $checkbox.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Regular)
        $checkbox.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $checkbox.Cursor = [System.Windows.Forms.Cursors]::Hand

        # Add tooltip if description provided
        if (-not [string]::IsNullOrEmpty($Description)) {
            $tooltip = New-ToolTip -Text $Description
            if ($null -ne $tooltip) {
                $tooltip.SetToolTip($checkbox, $Description)
            }
        }

        return $checkbox
    } catch {
        Write-Error "Failed to create checkbox '$Text': $_"
        return $null
    }
}

function New-ScrollablePanel {
    <#
    .SYNOPSIS
        Creates a scrollable panel for checkboxes
    #>
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)]
        [string]$Title,
        [Parameter(Mandatory)]
        [System.Drawing.Point]$Location,
        [Parameter(Mandatory)]
        [System.Drawing.Size]$Size
    )

    try {
        # Main panel with very subtle border
        $mainPanel = New-Object System.Windows.Forms.Panel
        $mainPanel.Location = $Location
        $mainPanel.Size = $Size
        $mainPanel.BackColor = Get-SafeColor -ColorName 'Surface' -DefaultColor ([System.Drawing.Color]::White)
        $mainPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::None

        $mainPanel.Add_Paint({
            param($sender, $e)
            $borderColor = [System.Drawing.Color]::FromArgb(230, 230, 230)
            $borderPen = New-Object System.Drawing.Pen($borderColor, 1)
            $width = [int]$sender.Width
            $height = [int]$sender.Height
            $rect = New-Object System.Drawing.Rectangle(0, 0, ($width - 1), ($height - 1))
            $e.Graphics.DrawRectangle($borderPen, $rect)
            $borderPen.Dispose()
        })

        # Title label
        $titleLabel = New-Object System.Windows.Forms.Label
        $titleLabel.Text = $Title
        $titleLabel.Location = New-Object System.Drawing.Point(15, 12)
        $titleWidth = [int]$Size.Width
        $titleLabel.Size = New-Object System.Drawing.Size(($titleWidth - 30), 22)
        $titleLabel.BackColor = [System.Drawing.Color]::Transparent
        $titleLabel.ForeColor = Get-SafeColor -ColorName 'Text' -DefaultColor ([System.Drawing.Color]::Black)
        $titleLabel.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
        $mainPanel.Controls.Add($titleLabel)

        # Content panel - no scrolling needed since panels size to fit content
        $scrollPanel = New-Object System.Windows.Forms.Panel
        $scrollPanel.Location = New-Object System.Drawing.Point(10, 52)
        $scrollWidth = [int]$Size.Width
        $scrollHeight = [int]$Size.Height
        $scrollPanel.Size = New-Object System.Drawing.Size(($scrollWidth - 25), ($scrollHeight - 62))
        $scrollPanel.AutoScroll = $false
        $scrollPanel.BackColor = [System.Drawing.Color]::Transparent
        $mainPanel.Controls.Add($scrollPanel)

        return @{
            MainPanel = $mainPanel
            ScrollPanel = $scrollPanel
        }
    } catch {
        Write-Error "Failed to create scrollable panel '$Title': $_"
        return $null
    }
}

function Apply-Enhancements {
    <#
    .SYNOPSIS
        Applies selected enhancements to the current system
    #>
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)]
        [hashtable]$SelectedOptions
    )

    $results = @()

    if ($null -eq $SelectedOptions -or $SelectedOptions.Count -eq 0) {
        return @('No options selected')
    }

    foreach ($category in $SelectedOptions.Keys) {
        $categoryOptions = $SelectedOptions[$category]
        if ($null -eq $categoryOptions) { continue }

        foreach ($option in $categoryOptions) {
            if ($null -eq $option) { continue }

            try {
                # Handle special cases that require PowerShell commands
                if ($option.Name -eq 'Disable Hibernation') {
                    try {
                        & powercfg.exe /hibernate off | Out-Null
                        $results += "Applied: $($option.Name)"
                    } catch {
                        $results += "Failed: $($option.Name) - Hibernate disable failed: $_"
                    }
                    continue
                }

                # Validate registry settings
                if ([string]::IsNullOrEmpty($option.RegistryPath)) {
                    $results += "Failed: $($option.Name) - Invalid registry path"
                    continue
                }

                # Registry name can be empty ONLY if it's explicitly '(Default)'
                if ([string]::IsNullOrWhiteSpace($option.RegistryName) -and $option.RegistryName -ne '(Default)') {
                    $results += "Failed: $($option.Name) - Invalid registry name"
                    continue
                }

                # Validate registry path format
                if ($option.RegistryPath -notmatch '^HK(LM|CU|CC|U|CR):\\') {
                    $results += "Failed: $($option.Name) - Invalid registry path format"
                    continue
                }

                # Create registry path and all parent paths if they don't exist
                if (-not (Test-Path -Path $option.RegistryPath -ErrorAction SilentlyContinue)) {
                    try {
                        # Create the full path including all missing parent paths
                        $null = New-Item -Path $option.RegistryPath -Force -ErrorAction Stop
                        Write-Verbose "Created registry path: $($option.RegistryPath)"
                    } catch {
                        # If direct creation fails, try creating parent paths step by step
                        try {
                            $pathParts = $option.RegistryPath -split '\\'
                            $currentPath = $pathParts[0]

                            # Special handling for common paths that need to be created
                            Write-Verbose "Creating registry path step by step: $($option.RegistryPath)"

                            for ($i = 1; $i -lt $pathParts.Length; $i++) {
                                $currentPath += '\' + $pathParts[$i]
                                if (-not (Test-Path -Path $currentPath -ErrorAction SilentlyContinue)) {
                                    $null = New-Item -Path $currentPath -Force -ErrorAction Stop
                                    Write-Verbose "Created intermediate path: $currentPath"
                                }
                            }
                            Write-Verbose "Successfully created full registry path: $($option.RegistryPath)"
                        } catch {
                            $results += "Failed: $($option.Name) - Could not create registry path: $_"
                            continue
                        }
                    }
                }

                # Apply registry setting based on value type
                $isDefaultValue = ($option.RegistryName -eq '(Default)')

                if ($isDefaultValue) {
                    # Handle default registry value (no -Name parameter)
                    if ($option.RegistryValue -is [string]) {
                        Set-ItemProperty -Path $option.RegistryPath -Value $option.RegistryValue -ErrorAction Stop
                    } else {
                        # For default values, we need to use Set-Item instead of Set-ItemProperty for non-string types
                        Set-Item -Path $option.RegistryPath -Value $option.RegistryValue -ErrorAction Stop
                    }
                } else {
                    # Handle named registry value
                    if ($option.RegistryValue -is [string]) {
                        Set-ItemProperty -Path $option.RegistryPath -Name $option.RegistryName -Value $option.RegistryValue -Type String -ErrorAction Stop
                    } else {
                        Set-ItemProperty -Path $option.RegistryPath -Name $option.RegistryName -Value $option.RegistryValue -Type DWord -ErrorAction Stop
                    }
                }

                # Verify the setting was applied
                try {
                    if ($isDefaultValue) {
                        # Verify default value
                        $verifyValue = Get-ItemProperty -Path $option.RegistryPath -ErrorAction Stop
                        $results += "Applied: $($option.Name) - Verified"
                    } else {
                        # Verify named value
                        $verifyValue = Get-ItemProperty -Path $option.RegistryPath -Name $option.RegistryName -ErrorAction Stop
                        $results += "Applied: $($option.Name) - Verified"
                    }
                } catch {
                    $results += "Applied: $($option.Name) - Warning: Could not verify setting"
                }

            } catch {
                # Provide more specific error messages
                $errorMessage = $_.Exception.Message
                if ($errorMessage -like "*Access is denied*") {
                    $results += "Failed: $($option.Name) - Access denied. Run as Administrator."
                } elseif ($errorMessage -like "*Cannot find path*") {
                    $results += "Failed: $($option.Name) - Registry path not found: $($option.RegistryPath)"
                } elseif ($errorMessage -like "*Cannot bind argument to parameter*") {
                    $results += "Failed: $($option.Name) - Invalid parameter (likely empty registry name)"
                } else {
                    $results += "Failed: $($option.Name) - $errorMessage"
                }
                Write-Verbose "Registry operation failed for $($option.Name): $errorMessage"
            }
        }
    }

    return $results
}

function Generate-UnattendedFile {
    <#
    .SYNOPSIS
        Generates an unattended installation file based on selected options
    #>
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)]
        [hashtable]$SelectedOptions
    )

    try {
        # Create the unattend.xml content
        $xmlContent = @'
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="windowsPE">
        <component name="Microsoft-Windows-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">
'@

        # Add bypass options if selected
        if ($SelectedOptions.ContainsKey('bypass') -and $null -ne $SelectedOptions.bypass) {
            $xmlContent += "`n            <RunSynchronous>"

            $commandOrder = 1
            foreach ($option in $SelectedOptions.bypass) {
                if ($null -eq $option) { continue }

                switch ($option.RegistryName) {
                    'BypassTPMCheck' {
                        $xmlContent += "`n                <RunSynchronousCommand wcm:action=`"add`">"
                        $xmlContent += "`n                    <Order>$commandOrder</Order>"
                        $xmlContent += "`n                    <Description>Bypass TPM 2.0 Requirement</Description>"
                        $xmlContent += "`n                    <Path>reg add HKLM\SYSTEM\Setup\LabConfig /v BypassTPMCheck /t REG_DWORD /d 1 /f</Path>"
                        $xmlContent += "`n                </RunSynchronousCommand>"
                        $commandOrder++
                    }
                    'BypassSecureBootCheck' {
                        $xmlContent += "`n                <RunSynchronousCommand wcm:action=`"add`">"
                        $xmlContent += "`n                    <Order>$commandOrder</Order>"
                        $xmlContent += "`n                    <Description>Bypass Secure Boot Requirement</Description>"
                        $xmlContent += "`n                    <Path>reg add HKLM\SYSTEM\Setup\LabConfig /v BypassSecureBootCheck /t REG_DWORD /d 1 /f</Path>"
                        $xmlContent += "`n                </RunSynchronousCommand>"
                        $commandOrder++
                    }
                    'BypassRAMCheck' {
                        $xmlContent += "`n                <RunSynchronousCommand wcm:action=`"add`">"
                        $xmlContent += "`n                    <Order>$commandOrder</Order>"
                        $xmlContent += "`n                    <Description>Bypass RAM Requirement</Description>"
                        $xmlContent += "`n                    <Path>reg add HKLM\SYSTEM\Setup\LabConfig /v BypassRAMCheck /t REG_DWORD /d 1 /f</Path>"
                        $xmlContent += "`n                </RunSynchronousCommand>"
                        $commandOrder++
                    }
                    'BypassCPUCheck' {
                        $xmlContent += "`n                <RunSynchronousCommand wcm:action=`"add`">"
                        $xmlContent += "`n                    <Order>$commandOrder</Order>"
                        $xmlContent += "`n                    <Description>Bypass CPU Requirement</Description>"
                        $xmlContent += "`n                    <Path>reg add HKLM\SYSTEM\Setup\LabConfig /v BypassCPUCheck /t REG_DWORD /d 1 /f</Path>"
                        $xmlContent += "`n                </RunSynchronousCommand>"
                        $commandOrder++
                    }
                    'BypassStorageCheck' {
                        $xmlContent += "`n                <RunSynchronousCommand wcm:action=`"add`">"
                        $xmlContent += "`n                    <Order>$commandOrder</Order>"
                        $xmlContent += "`n                    <Description>Bypass Storage Requirement</Description>"
                        $xmlContent += "`n                    <Path>reg add HKLM\SYSTEM\Setup\LabConfig /v BypassStorageCheck /t REG_DWORD /d 1 /f</Path>"
                        $xmlContent += "`n                </RunSynchronousCommand>"
                        $commandOrder++
                    }
                    'BypassNRO' {
                        $xmlContent += "`n                <RunSynchronousCommand wcm:action=`"add`">"
                        $xmlContent += "`n                    <Order>$commandOrder</Order>"
                        $xmlContent += "`n                    <Description>Skip OOBE Network Connection</Description>"
                        $xmlContent += "`n                    <Path>reg add `"HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE`" /v BypassNRO /t REG_DWORD /d 1 /f</Path>"
                        $xmlContent += "`n                </RunSynchronousCommand>"
                        $commandOrder++
                    }
                    'BypassMSAOOBE' {
                        $xmlContent += "`n                <RunSynchronousCommand wcm:action=`"add`">"
                        $xmlContent += "`n                    <Order>$commandOrder</Order>"
                        $xmlContent += "`n                    <Description>Install Without Microsoft Account</Description>"
                        $xmlContent += "`n                    <Path>reg add `"HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE`" /v BypassMSAOOBE /t REG_DWORD /d 1 /f</Path>"
                        $xmlContent += "`n                </RunSynchronousCommand>"
                        $commandOrder++
                    }
                }
            }
            $xmlContent += "`n            </RunSynchronous>"
        }

        $xmlContent += @'
        </component>
    </settings>

    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">
            <FirstLogonCommands>
'@

        # Add post-installation commands for other categories
        $commandOrder = 1
        foreach ($category in $SelectedOptions.Keys) {
            if ($category -eq 'bypass') { continue }

            $categoryOptions = $SelectedOptions[$category]
            if ($null -eq $categoryOptions) { continue }

            foreach ($option in $categoryOptions) {
                if ($null -eq $option -or [string]::IsNullOrEmpty($option.RegistryPath) -or [string]::IsNullOrEmpty($option.RegistryName)) {
                    continue
                }

                # Convert PowerShell registry path to reg.exe format
                $regPath = $option.RegistryPath -replace 'HKLM:', 'HKLM' -replace 'HKCU:', 'HKCU'

                # Determine registry value type and format command
                if ($option.RegistryValue -is [string]) {
                    if ($option.RegistryValue -eq '') {
                        $regCommand = "reg add `"$regPath`" /v `"$($option.RegistryName)`" /t REG_SZ /d `"`" /f"
                    } else {
                        $regCommand = "reg add `"$regPath`" /v `"$($option.RegistryName)`" /t REG_SZ /d `"$($option.RegistryValue)`" /f"
                    }
                } else {
                    $regCommand = "reg add `"$regPath`" /v `"$($option.RegistryName)`" /t REG_DWORD /d $($option.RegistryValue) /f"
                }

                # Handle special cases
                if ($option.Name -eq 'Disable Hibernation') {
                    $regCommand = 'powercfg.exe /hibernate off'
                }

                $xmlContent += "`n                <SynchronousCommand wcm:action=`"add`">"
                $xmlContent += "`n                    <Order>$commandOrder</Order>"
                $xmlContent += "`n                    <Description>$($option.Name)</Description>"
                $xmlContent += "`n                    <CommandLine>$regCommand</CommandLine>"
                $xmlContent += "`n                </SynchronousCommand>"
                $commandOrder++
            }
        }

        $xmlContent += @'
            </FirstLogonCommands>
            <OOBE>
                <HideEULAPage>true</HideEULAPage>
                <HideLocalAccountScreen>false</HideLocalAccountScreen>
                <HideOEMRegistrationScreen>true</HideOEMRegistrationScreen>
                <HideOnlineAccountScreens>true</HideOnlineAccountScreens>
                <HideWirelessSetupInOOBE>false</HideWirelessSetupInOOBE>
                <NetworkLocation>Home</NetworkLocation>
                <ProtectYourPC>1</ProtectYourPC>
                <SkipUserOOBE>false</SkipUserOOBE>
                <SkipMachineOOBE>false</SkipMachineOOBE>
            </OOBE>
            <UserAccounts>
                <LocalAccounts>
                    <LocalAccount wcm:action="add">
                        <Password>
                            <Value></Value>
                            <PlainText>true</PlainText>
                        </Password>
                        <Description>Local Administrator Account</Description>
                        <DisplayName>Administrator</DisplayName>
                        <Group>Administrators</Group>
                        <Name>Admin</Name>
                    </LocalAccount>
                </LocalAccounts>
            </UserAccounts>
        </component>
    </settings>
</unattend>
'@

        # Generate standard autounattend filename
        $fileName = "autounattend.xml"
        $filePath = Join-Path -Path $PWD -ChildPath $fileName

        # Save file with UTF-8 encoding
        [System.IO.File]::WriteAllText($filePath, $xmlContent, [System.Text.Encoding]::UTF8)

        return @{
            Success = $true
            FilePath = $filePath
            FileName = $fileName
            Message = 'Unattended install file generated successfully'
        }
    } catch {
        return @{
            Success = $false
            FilePath = $null
            FileName = $null
            Message = "Failed to generate unattended file: $_"
        }
    }
}

function Show-EnhancementTool {
    <#
    .SYNOPSIS
        Main function to display the GUI tool
    #>
    [CmdletBinding()]
    param()

    try {
        # Initialize color scheme
        Set-ColorScheme

        # Create main form with dynamic sizing based on content
        $form = New-Object System.Windows.Forms.Form
        $form.Text = 'Windows 11 Ultimate Configurator'
        $form.BackColor = Get-SafeColor -ColorName 'Background' -DefaultColor ([System.Drawing.Color]::FromArgb(243, 243, 243))
        $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Sizable
        $form.MaximizeBox = $true
        $form.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Regular)

        # Pre-calculate content dimensions for dynamic sizing
        $panelSpacing = 20
        $startX = 30
        $marginRight = 30
        $panelsPerRow = 4
        $padding = 30

        # Calculate optimal window width based on content with explicit type conversion
        $minPanelWidth = [int]300
        $optimalWidth = ([int]$minPanelWidth * [int]$panelsPerRow) + ([int]$panelSpacing * ([int]$panelsPerRow - 1)) + [int]$startX + [int]$marginRight + ([int]$padding * 2)

        # Set initial size (will be adjusted after content is measured)
        $form.Size = New-Object System.Drawing.Size([int]$optimalWidth, [int]800)
        $minFormWidth = ([int]$minPanelWidth * 2) + [int]$startX + [int]$marginRight + ([int]$padding * 2)
        $form.MinimumSize = New-Object System.Drawing.Size([int]$minFormWidth, [int]600)
        $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

        # Add main scrollable container for the entire form
        $mainScrollContainer = New-Object System.Windows.Forms.Panel
        $mainScrollContainer.Location = New-Object System.Drawing.Point(0, 0)
        $mainScrollContainer.Size = New-Object System.Drawing.Size([int]$form.ClientSize.Width, [int]$form.ClientSize.Height)
        $mainScrollContainer.AutoScroll = $true
        $mainScrollContainer.BackColor = $form.BackColor
        $form.Controls.Add($mainScrollContainer)

        # Header label with consistent padding
        $headerLabel = New-Object System.Windows.Forms.Label
        $headerLabel.Text = 'Windows 11 Ultimate Configurator'
        $headerLabel.Location = New-Object System.Drawing.Point(([int]$startX + [int]$padding), [int]$padding)
        $headerLabel.Size = New-Object System.Drawing.Size([int]800, [int]30)
        $headerLabel.BackColor = [System.Drawing.Color]::Transparent
        $headerLabel.ForeColor = Get-SafeColor -ColorName 'Text' -DefaultColor ([System.Drawing.Color]::Black)
        $headerLabel.Font = New-Object System.Drawing.Font('Segoe UI', 18, [System.Drawing.FontStyle]::Bold)
        $mainScrollContainer.Controls.Add($headerLabel)

        # Subtitle label with consistent padding
        $subtitleLabel = New-Object System.Windows.Forms.Label
        $subtitleLabel.Text = 'Professional system enhancement and Windows 11 requirements bypass - 51 total options organized by category'
        $subtitleLabel.Location = New-Object System.Drawing.Point(([int]$startX + [int]$padding), ([int]$padding + [int]35))
        $subtitleLabel.Size = New-Object System.Drawing.Size([int]1000, [int]20)
        $subtitleLabel.BackColor = [System.Drawing.Color]::Transparent
        $subtitleLabel.ForeColor = Get-SafeColor -ColorName 'TextSecondary' -DefaultColor ([System.Drawing.Color]::Gray)
        $subtitleLabel.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Regular)
        $mainScrollContainer.Controls.Add($subtitleLabel)

        # Initialize global arrays for checkboxes
        $Global:bypassCheckboxes = @()
        $Global:enhancementCheckboxes = @()

        # Add some space between header and warning box with explicit type conversion
        $warningTop = [int]$padding + [int]35 + [int]25 + [int]25

        # Add warning box with improved appearance and dynamic sizing
        $warningText = 'CAUTION: This utility modifies critical Windows settings and bypasses hardware requirements. Use only on test systems or if you understand the risks. Always backup your system before applying changes.'
        $warningFont = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Regular)

        # Calculate required height for text with better fitting and explicit type conversion
        $tempGraphics = [System.Drawing.Graphics]::FromImage((New-Object System.Drawing.Bitmap(1, 1)))
        $formWidthInt = [int]$form.Width
        $measureWidth = [int]$formWidthInt - [int]140
        $textSize = $tempGraphics.MeasureString($warningText, $warningFont, $measureWidth)
        $tempGraphics.Dispose()
        $textHeight = [int]([Math]::Ceiling([double]$textSize.Height))
        $warningHeight = [Math]::Max([int]45, ($textHeight + [int]20))

        $warningPanel = New-Object System.Windows.Forms.Panel
        $warningPanel.Location = New-Object System.Drawing.Point(([int]$startX + [int]$padding), [int]$warningTop)
        $formWidthForPanel = [int]$form.Width
        $panelWidth = [int]$formWidthForPanel - ([int]$startX + [int]$marginRight + ([int]$padding * 2))
        $warningPanel.Size = New-Object System.Drawing.Size([int]$panelWidth, [int]$warningHeight)
        $warningPanel.BackColor = [System.Drawing.Color]::FromArgb(255, 249, 232)
        $warningPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::None

        # Add custom subtle border using PowerShell 5.1 compatible method
        $warningPanel.Add_Paint({
            param($sender, $e)
            $borderColor = [System.Drawing.Color]::FromArgb(200, 180, 120)
            $borderPen = New-Object System.Drawing.Pen($borderColor, 1)
            $panelWidth = [int]$sender.Width
            $panelHeight = [int]$sender.Height
            $rect = New-Object System.Drawing.Rectangle(0, 0, ($panelWidth - 1), ($panelHeight - 1))
            $e.Graphics.DrawRectangle($borderPen, $rect)
            $borderPen.Dispose()
        })

        $warningLabel = New-Object System.Windows.Forms.Label
        $warningLabel.Text = $warningText
        $warningLabel.Location = New-Object System.Drawing.Point([int]15, [int]10)
        $warningPanelWidth = [int]$warningPanel.Width
        $labelWidth = [int]$warningPanelWidth - [int]30
        $labelHeight = [int]$warningHeight - [int]20
        $warningLabel.Size = New-Object System.Drawing.Size([int]$labelWidth, [int]$labelHeight)
        $warningLabel.Font = $warningFont
        $warningLabel.ForeColor = [System.Drawing.Color]::FromArgb(120, 80, 20)
        $warningLabel.BackColor = [System.Drawing.Color]::Transparent
        $warningPanel.Controls.Add($warningLabel)

        $mainScrollContainer.Controls.Add($warningPanel)

        # Move buttons under the caution box with explicit type conversion
        $buttonsY = [int]$warningTop + [int]$warningHeight + [int]25

        # Define responsive panel layout configuration (adjusted for buttons position)
        # Use the pre-calculated values from form initialization
        $startY = [int]$buttonsY + [int]60

        # Calculate optimal panel sizes based on content and available space
        $formWidthInt = [int]$form.Width
        $availableWidth = [int]$formWidthInt - [int]$startX - [int]$marginRight - ([int]$padding * 2)

        # Calculate panel width to use available space efficiently
        $spacingWidth = ([int]$panelsPerRow - 1) * [int]$panelSpacing
        $calculatedPanelWidth = [Math]::Floor(([int]$availableWidth - [int]$spacingWidth) / [int]$panelsPerRow)
        $panelWidth = [Math]::Max([int]$calculatedPanelWidth, [int]$minPanelWidth)

        # Define all categories with their information (Developer section removed)
        $allCategories = @(
            @{ Name = 'Windows 11 Bypass'; Key = 'bypass'; Count = 7; Description = 'Skip hardware requirements' },
            @{ Name = 'Privacy'; Key = 'privacy'; Count = 10; Description = 'Disable tracking & telemetry' },
            @{ Name = 'Security'; Key = 'security'; Count = 8; Description = 'Enhanced system security' },
            @{ Name = 'Performance'; Key = 'performance'; Count = 6; Description = 'Speed & responsiveness' },
            @{ Name = 'Appearance'; Key = 'appearance'; Count = 5; Description = 'UI customization' },
            @{ Name = 'Gaming'; Key = 'gaming'; Count = 6; Description = 'Gaming optimizations' },
            @{ Name = 'Network'; Key = 'network'; Count = 6; Description = 'Network & internet' },
            @{ Name = 'Cleanup'; Key = 'cleanup'; Count = 7; Description = 'Remove bloatware' }
        )

        # Create panels in responsive grid layout with consistent padding
        $currentX = [int]$startX + [int]$padding
        $currentY = [int]$startY
        $currentPanel = 0

        # First pass: Calculate the height needed for each panel and determine max height per row
        $panelHeights = @()
        $rowMaxHeights = @()
        $currentRowMax = 0

        foreach ($categoryInfo in $allCategories) {
            $categoryKey = if ($categoryInfo.Key -eq 'bypass') { 'bypass' } else { $categoryInfo.Key }
            $optionCount = $Global:enhancementOptions[$categoryKey].Count

            # Calculate height: header(34) + description(16) + options(20px each) + padding(15)
            $individualPanelHeight = [int]34 + [int]16 + ([int]$optionCount * [int]20) + [int]15
            $individualPanelHeight = [Math]::Max([int]$individualPanelHeight, [int]120)
            $panelHeights += $individualPanelHeight

            # Track max height in current row
            $currentRowMax = [Math]::Max($currentRowMax, $individualPanelHeight)

            # If we've completed a row (or it's the last panel), save the row height
            if (($panelHeights.Count % $panelsPerRow) -eq 0 -or $panelHeights.Count -eq $allCategories.Count) {
                $rowMaxHeights += $currentRowMax
                $currentRowMax = 0
            }
        }

        # Second pass: Create panels using the row maximum heights
        $panelIndex = 0
        foreach ($categoryInfo in $allCategories) {
            # Determine which row this panel is in and use that row's max height
            $rowNumber = [Math]::Floor($panelIndex / $panelsPerRow)
            $uniformRowHeight = $rowMaxHeights[$rowNumber]

            # Calculate position based on completed rows
            if ($currentPanel -gt 0 -and ($currentPanel % $panelsPerRow) -eq 0) {
                $currentX = [int]$startX + [int]$padding
                $currentY = [int]$startY

                for ($i = 0; $i -lt $rowNumber; $i++) {
                    $currentY += ([int]$rowMaxHeights[$i] + [int]$panelSpacing)
                }
            }

            # Create panel for this category using uniform row height
            $panelTitle = "$($categoryInfo.Name) ($($categoryInfo.Count) options)"
            $panelLocation = New-Object System.Drawing.Point([int]$currentX, [int]$currentY)
            $panelSize = New-Object System.Drawing.Size([int]$panelWidth, [int]$uniformRowHeight)

            $categoryPanelInfo = New-ScrollablePanel -Title $panelTitle -Location $panelLocation -Size $panelSize

            if ($null -ne $categoryPanelInfo) {
                $mainScrollContainer.Controls.Add($categoryPanelInfo.MainPanel)

                # Add description label with better positioning
                $descLabel = New-Object System.Windows.Forms.Label
                $descLabel.Text = $categoryInfo.Description
                $descLabel.Location = New-Object System.Drawing.Point([int]15, [int]34)
                $panelWidthForDesc = [int]$panelWidth
                $descWidth = [int]$panelWidthForDesc - [int]30
                $descLabel.Size = New-Object System.Drawing.Size([int]$descWidth, [int]16)
                $descLabel.BackColor = [System.Drawing.Color]::Transparent
                $descLabel.ForeColor = Get-SafeColor -ColorName 'TextSecondary' -DefaultColor ([System.Drawing.Color]::Gray)
                $descLabel.Font = New-Object System.Drawing.Font('Segoe UI', 8, [System.Drawing.FontStyle]::Italic)
                $categoryPanelInfo.MainPanel.Controls.Add($descLabel)

                # Create checkboxes for this category
                $yPos = 5
                $categoryOptions = if ($categoryInfo.Key -eq 'bypass') { $Global:enhancementOptions.bypass } else { $Global:enhancementOptions[$categoryInfo.Key] }

                if ($null -ne $categoryOptions) {
                    foreach ($option in $categoryOptions) {
                        if ($null -eq $option) { continue }

                        $checkbox = New-ModernCheckBox -Text $option.Name -Location (New-Object System.Drawing.Point([int]5, [int]$yPos)) -Description $option.Description
                        if ($null -ne $checkbox) {
                            # Adjust checkbox size for smaller panels
                            $checkboxWidth = [int]$panelWidth - [int]50
                            $checkbox.Size = New-Object System.Drawing.Size([int]$checkboxWidth, [int]18)
                            $checkbox.Font = New-Object System.Drawing.Font('Segoe UI', 8, [System.Drawing.FontStyle]::Regular)

                            $categoryPanelInfo.ScrollPanel.Controls.Add($checkbox)

                            # Add to appropriate global array
                            if ($categoryInfo.Key -eq 'bypass') {
                                $Global:bypassCheckboxes += @{ Control = $checkbox; Option = $option }
                            } else {
                                $Global:enhancementCheckboxes += @{ Control = $checkbox; Option = $option }
                            }

                            $yPos += [int]20
                        }
                    }
                }
            }

            # Move to next position
            $panelWidthInt = [int]$panelWidth
            $currentX += ([int]$panelWidthInt + [int]$panelSpacing)
            $currentPanel++
            $panelIndex++
        }

        # Position buttons under caution box with consistent padding
        $buttonStartX = [int]$startX + [int]$padding
        $formWidthInt = [int]$form.Width
        $buttonEndX = [int]$formWidthInt - [int]$padding - [int]$marginRight
        $availableButtonWidth = [int]$buttonEndX - [int]$buttonStartX
        $buttonSpacing = [int]15
        $buttonHeight = [int]35
        $buttonFont = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Regular)

        # All buttons in one array for fluid layout
        $allButtons = @(
            @{ Text = 'Bypass'; MinWidth = 80; Category = 'bypass'; Type = 'category' },
            @{ Text = 'Privacy'; MinWidth = 80; Category = 'privacy'; Type = 'category' },
            @{ Text = 'Security'; MinWidth = 80; Category = 'security'; Type = 'category' },
            @{ Text = 'Performance'; MinWidth = 100; Category = 'performance'; Type = 'category' },
            @{ Text = 'Appearance'; MinWidth = 100; Category = 'appearance'; Type = 'category' },
            @{ Text = 'Gaming'; MinWidth = 80; Category = 'gaming'; Type = 'category' },
            @{ Text = 'Network'; MinWidth = 80; Category = 'network'; Type = 'category' },
            @{ Text = 'Cleanup'; MinWidth = 80; Category = 'cleanup'; Type = 'category' },
            @{ Text = 'Select All'; MinWidth = 90; Type = 'selectall' },
            @{ Text = 'Clear All'; MinWidth = 90; Type = 'clearall' },
            @{ Text = 'Apply'; MinWidth = 80; Type = 'apply' },
            @{ Text = 'Generate'; MinWidth = 90; Type = 'generate' },
            @{ Text = 'Exit'; MinWidth = 70; Type = 'exit' }
        )

        # Calculate optimal button widths
        foreach ($btn in $allButtons) {
            $textWidth = Get-TextWidth -Text $btn.Text -Font $buttonFont
            $textWidthInt = [int]$textWidth
            $minWidthInt = [int]$btn.MinWidth
            $btn.OptimalWidth = [Math]::Max($textWidthInt, $minWidthInt)
        }

        # Create all buttons in one fluid row under caution box
        $currentX = $buttonStartX

        foreach ($buttonInfo in $allButtons) {
            $buttonColor = 'Primary'

            # Set appropriate colors
            switch ($buttonInfo.Type) {
                'clearall' { $buttonColor = 'Warning' }
                'apply' { $buttonColor = 'Success' }
                'generate' { $buttonColor = 'Success' }
                'exit' { $buttonColor = 'TextSecondary' }
            }

            $button = New-ModernButton -Text $buttonInfo.Text -Location (New-Object System.Drawing.Point([int]$currentX, [int]$buttonsY)) -Size (New-Object System.Drawing.Size([int]$buttonInfo.OptimalWidth, [int]$buttonHeight)) -BackColor $buttonColor

            if ($null -ne $button) {
                # Add appropriate event handler based on button type
                switch ($buttonInfo.Type) {
                    'category' {
                        $button.Tag = $buttonInfo.Category
                        $button.Add_Click({
                            $selectedCategory = $this.Tag
                            if ($selectedCategory -eq 'bypass') {
                                foreach ($item in $Global:bypassCheckboxes) {
                                    if ($null -ne $item.Control) {
                                        $item.Control.Checked = $true
                                    }
                                }
                            } else {
                                foreach ($item in $Global:enhancementCheckboxes) {
                                    if ($null -ne $item.Control -and $null -ne $item.Option -and $item.Option.Category -eq $selectedCategory) {
                                        $item.Control.Checked = $true
                                    }
                                }
                            }
                        })
                    }
                    'selectall' {
                        $button.Add_Click({
                            # Select all bypass checkboxes
                            foreach ($item in $Global:bypassCheckboxes) {
                                if ($null -ne $item.Control) {
                                    $item.Control.Checked = $true
                                }
                            }
                            # Select all enhancement checkboxes
                            foreach ($item in $Global:enhancementCheckboxes) {
                                if ($null -ne $item.Control) {
                                    $item.Control.Checked = $true
                                }
                            }
                        })
                    }
                    'clearall' {
                        $button.Add_Click({
                            # Clear all bypass checkboxes
                            foreach ($item in $Global:bypassCheckboxes) {
                                if ($null -ne $item.Control) {
                                    $item.Control.Checked = $false
                                }
                            }
                            # Clear all enhancement checkboxes
                            foreach ($item in $Global:enhancementCheckboxes) {
                                if ($null -ne $item.Control) {
                                    $item.Control.Checked = $false
                                }
                            }
                        })
                    }
                    'apply' {
                        $button.Add_Click({
                            try {
                                $selectedOptions = & $collectSelectedOptions

                                if ($selectedOptions.Count -eq 0) {
                                    [System.Windows.Forms.MessageBox]::Show('Please select at least one option to apply.', 'No Options Selected', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
                                    return
                                }

                                # Confirm before applying changes
                                $result = [System.Windows.Forms.MessageBox]::Show('This will modify your current Windows system with the selected options.' + [Environment]::NewLine + [Environment]::NewLine + 'Are you sure you want to continue?', 'Confirm System Changes', [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
                                if ($result -eq [System.Windows.Forms.DialogResult]::No) {
                                    return
                                }

                                $results = Apply-Enhancements -SelectedOptions $selectedOptions

                                if ($null -ne $results -and $results.Count -gt 0) {
                                    $resultText = $results -join [Environment]::NewLine
                                    [System.Windows.Forms.MessageBox]::Show($resultText, 'System Modification Results', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                                }
                            } catch {
                                [System.Windows.Forms.MessageBox]::Show("An error occurred: $_", 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                            }
                        })
                    }
                    'generate' {
                        $button.Add_Click({
                            try {
                                $selectedOptions = & $collectSelectedOptions

                                if ($selectedOptions.Count -eq 0) {
                                    [System.Windows.Forms.MessageBox]::Show('Please select at least one option to generate the unattended file.', 'No Options Selected', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
                                    return
                                }

                                # Generate unattended install file
                                $result = Generate-UnattendedFile -SelectedOptions $selectedOptions

                                if ($result.Success) {
                                    $message = "$($result.Message)" + [Environment]::NewLine + [Environment]::NewLine +
                                               "File saved as: $($result.FileName)" + [Environment]::NewLine +
                                               "Location: $($result.FilePath)" + [Environment]::NewLine + [Environment]::NewLine +
                                               "To use this file:" + [Environment]::NewLine +
                                               "1. Copy 'autounattend.xml' to the root of your Windows 11 ISO or USB drive" + [Environment]::NewLine +
                                               "2. Windows will automatically detect and use this file during installation"
                                    [System.Windows.Forms.MessageBox]::Show($message, 'Unattended File Generated', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)

                                    # Ask if user wants to open the file location
                                    $openResult = [System.Windows.Forms.MessageBox]::Show('Would you like to open the file location?', 'Open File Location', [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
                                    if ($openResult -eq [System.Windows.Forms.DialogResult]::Yes) {
                                        Start-Process -FilePath 'explorer.exe' -ArgumentList "/select,`"$($result.FilePath)`""
                                    }
                                } else {
                                    [System.Windows.Forms.MessageBox]::Show($result.Message, 'Generation Failed', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                                }
                            } catch {
                                [System.Windows.Forms.MessageBox]::Show("An error occurred: $_", 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                            }
                        })
                    }
                    'exit' {
                        $button.Add_Click({ $form.Close() })
                    }
                }

                $mainScrollContainer.Controls.Add($button)
            }

            $optimalWidthInt = [int]$buttonInfo.OptimalWidth
            $currentX += ([int]$optimalWidthInt + [int]$buttonSpacing)
        }



        # Helper function to collect selected options
        $collectSelectedOptions = {
            $selectedOptions = @{}

            # Collect selected bypass options
            $bypassSelected = @()
            foreach ($item in $Global:bypassCheckboxes) {
                if ($null -ne $item.Control -and $item.Control.Checked -and $null -ne $item.Option) {
                    $bypassSelected += $item.Option
                }
            }
            if ($bypassSelected.Count -gt 0) {
                $selectedOptions['bypass'] = $bypassSelected
            }

            # Collect selected enhancement options by category
            $categories = @('privacy', 'security', 'performance', 'appearance', 'gaming', 'network', 'cleanup')
            foreach ($category in $categories) {
                $categorySelected = @()
                foreach ($item in $Global:enhancementCheckboxes) {
                    if ($null -ne $item.Control -and $item.Control.Checked -and $null -ne $item.Option -and $item.Option.Category -eq $category) {
                        $categorySelected += $item.Option
                    }
                }
                if ($categorySelected.Count -gt 0) {
                    $selectedOptions[$category] = $categorySelected
                }
            }

            return $selectedOptions
        }

        # Calculate the total content height and position status bar below panels
        $totalRowsHeight = [int]0
        foreach ($rowHeight in $rowMaxHeights) {
            $totalRowsHeight += ([int]$rowHeight + [int]$panelSpacing)
        }
        $maxPanelY = [int]$startY + [int]$totalRowsHeight - [int]$panelSpacing
        $statusY = [int]$maxPanelY + [int]20

        # Calculate optimal window height based on actual content
        $totalContentHeight = [int]$statusY + [int]50 + ([int]$padding * 2)

        # Adjust form size to fit content with padding (min height 600)
        $optimalHeight = [Math]::Max([int]$totalContentHeight, [int]600)
        $form.Size = New-Object System.Drawing.Size([int]$form.Width, [int]$optimalHeight)

        # Adjust main scroll container to fit the new form size
        $mainScrollContainer.Size = New-Object System.Drawing.Size([int]$form.ClientSize.Width, [int]$form.ClientSize.Height)

        # Status bar with consistent padding
        $statusLabel = New-Object System.Windows.Forms.Label
        $statusLabel.Text = 'Ready - Select options from the panels above, then: Apply (modifies current PC) or Generate (creates install file)'
        $statusLabel.Location = New-Object System.Drawing.Point(([int]$startX + [int]$padding), [int]$statusY)
        $statusLabel.Size = New-Object System.Drawing.Size([int]1200, [int]20)
        $statusLabel.BackColor = [System.Drawing.Color]::Transparent
        $statusLabel.ForeColor = Get-SafeColor -ColorName 'TextSecondary' -DefaultColor ([System.Drawing.Color]::Gray)
        $statusLabel.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Regular)
        $mainScrollContainer.Controls.Add($statusLabel)

        # Calculate the total content height for scroll container
        $totalScrollHeight = [int]$statusY + [int]50
        $totalContentHeight = [Math]::Max([int]$totalScrollHeight, [int]1000)

        # Add resize event handler for responsive layout with scrolling support
        $form.Add_Resize({
            try {
                $mainScrollContainer.Size = New-Object System.Drawing.Size([int]$this.ClientSize.Width, [int]$this.ClientSize.Height)

                foreach ($control in $mainScrollContainer.Controls) {
                    if ($control -is [System.Windows.Forms.Panel] -and $control.BackColor -eq [System.Drawing.Color]::FromArgb(255, 249, 232)) {
                        $thisWidthInt = [int]$this.Width
                        $newControlWidth = [int]$thisWidthInt - ([int]$startX + [int]$marginRight + ([int]$padding * 2))
                        $control.Size = New-Object System.Drawing.Size([int]$newControlWidth, [int]$warningHeight)
                        foreach ($subControl in $control.Controls) {
                            if ($subControl -is [System.Windows.Forms.Label] -and $subControl.Location.X -eq 15) {
                                $controlWidthInt = [int]$control.Width
                                $newLabelWidth = [int]$controlWidthInt - [int]30
                                $newLabelHeight = [int]$warningHeight - [int]20
                                $subControl.Size = New-Object System.Drawing.Size([int]$newLabelWidth, [int]$newLabelHeight)
                            }
                        }
                        break
                    }
                }

                <#
                Recalculate panel width on resize - panel heights remain fixed to content
                Only check for main panels not message boxes or buttons
                #>
                $thisWidthInt = [int]$this.Width
                $newAvailableWidth = [int]$thisWidthInt - [int]$startX - [int]$marginRight - ([int]$padding * 2)
                $newSpacingWidth = ([int]$panelsPerRow - 1) * [int]$panelSpacing
                $calculatedWidth = [Math]::Floor(([int]$newAvailableWidth - [int]$newSpacingWidth) / [int]$panelsPerRow)
                $newPanelWidth = [Math]::Max([int]$calculatedWidth, [int]$minPanelWidth)

                if ([Math]::Abs([int]$newPanelWidth - [int]$panelWidth) -gt [int]20) {
                    $panelWidth = $newPanelWidth

                    foreach ($control in $mainScrollContainer.Controls) {
                        $startYCheck = [int]$startY - [int]50
                        if ($control -is [System.Windows.Forms.Panel] -and $control.Location.Y -gt $startYCheck) {
                            $existingHeight = [int]$control.Size.Height
                            $control.Size = New-Object System.Drawing.Size([int]$newPanelWidth, [int]$existingHeight)
                        }
                    }
                }

            } catch {
                Write-Verbose "Resize error: $_"
            }
        })

        # Show the form
        Write-Host "Launching GUI..." -ForegroundColor Green
        [void]$form.ShowDialog()

    } catch {
        Write-Error "Failed to create main form: $_"
        [System.Windows.Forms.MessageBox]::Show("Failed to initialize the application: $_", 'Initialization Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

# Entry point with proper error handling
try {
    Write-Host "Starting Windows 11 Ultimate Configurator..." -ForegroundColor Cyan
    Show-EnhancementTool
} catch {
    Write-Error "Application failed to start: $_"
    [System.Windows.Forms.MessageBox]::Show("Application failed to start: $_", 'Critical Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    Read-Host "Press Enter to exit"
}

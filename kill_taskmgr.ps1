# PowerShell Script to Kill Task Manager (taskmgr.exe) Only After Long Idle Period in Background
# This is a temporary fix for Windows 11 where Task Manager lingers in background
# Affects: Windows 11 24H2, 25H2, and later versions
# GitHub: https://github.com/1LUC1D4710N/kill-taskmgr-script

# Add Windows API types for detecting user activity
Add-Type @"
    using System;
    using System.Runtime.InteropServices;

    public class UserActivityHelper {
        [StructLayout(LayoutKind.Sequential)]
        public struct LASTINPUTINFO {
            public uint cbSize;
            public uint dwTime;
        }

        [DllImport("user32.dll")]
        public static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

        [DllImport("user32.dll")]
        public static extern IntPtr GetForegroundWindow();

        [DllImport("user32.dll")]
        public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);
    }
"@

# Define a longer delay (in seconds) - user must be idle for this duration before killing Task Manager
$idleTimeBeforeKill = 30

# Track Task Manager processes and their last seen foreground time
$taskmgrTracking = @{}

while ($true) {
    try {
        # Get all instances of taskmgr.exe
        $taskmgrProcesses = Get-Process -Name taskmgr -ErrorAction SilentlyContinue

        # Get current foreground window process ID
        $fgWindow = [UserActivityHelper]::GetForegroundWindow()
        $fgPid = 0
        [UserActivityHelper]::GetWindowThreadProcessId($fgWindow, [ref]$fgPid) | Out-Null

        # Get current system idle time
        $lastInputInfo = New-Object UserActivityHelper+LASTINPUTINFO
        $lastInputInfo.cbSize = [System.Runtime.InteropServices.Marshal]::SizeOf($lastInputInfo)
        [UserActivityHelper]::GetLastInputInfo([ref]$lastInputInfo) | Out-Null
        $idleMs = [Environment]::TickCount - $lastInputInfo.dwTime
        $idleSecs = $idleMs / 1000

        if ($taskmgrProcesses) {
            foreach ($process in $taskmgrProcesses) {
                # Initialize tracking if this is a new process
                if (-not $taskmgrTracking.ContainsKey($process.Id)) {
                    $taskmgrTracking[$process.Id] = @{
                        'LastForegroundTime' = (Get-Date)
                        'ProcessId' = $process.Id
                    }
                }

                $isCurrentlyForeground = ($fgPid -eq $process.Id)

                if ($isCurrentlyForeground) {
                    # Update the last time it was in the foreground
                    $taskmgrTracking[$process.Id]['LastForegroundTime'] = (Get-Date)
                    Write-Output "Task Manager (PID: $($process.Id)) is active in foreground - idle time: $([math]::Round($idleSecs, 1))s"
                } else {
                    # Task Manager is in the background
                    $timeSinceLastForeground = (Get-Date) - $taskmgrTracking[$process.Id]['LastForegroundTime']
                    
                    if ($timeSinceLastForeground.TotalSeconds -ge $idleTimeBeforeKill -and $idleSecs -ge $idleTimeBeforeKill) {
                        Write-Output "Killing Task Manager (PID: $($process.Id)) - has been in background for $([math]::Round($timeSinceLastForeground.TotalSeconds, 1))s and user idle for $([math]::Round($idleSecs, 1))s."
                        Stop-Process -Id $process.Id -Force
                        $taskmgrTracking.Remove($process.Id) | Out-Null
                    } else {
                        $timeRemaining = $idleTimeBeforeKill - [math]::Min($timeSinceLastForeground.TotalSeconds, $idleSecs)
                        Write-Output "Task Manager (PID: $($process.Id)) in background - will kill if idle for another $([math]::Round($timeRemaining, 1))s (user idle: $([math]::Round($idleSecs, 1))s)"
                    }
                }
            }
        } else {
            # Clean up tracking for processes that no longer exist
            $taskmgrTracking = @{}
        }
    } catch {
        Write-Output "Error: $_"
    }

    # Wait for 5 seconds before checking again
    Start-Sleep -Seconds 5
}
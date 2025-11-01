# Task Manager Fix Script

## What This Script Does

This script solves a Windows bug where **Task Manager (taskmgr.exe) moves to the background and consumes memory** after you close it. The script automatically terminates Task Manager when it's running in the background AND you're not actively using your system.

## The Problem

In recent Windows versions, when you close Task Manager, it doesn't fully exit—instead, it moves to the background and keeps consuming memory. Each time you close it, it moves to the background again, eating up more RAM.

**Affected Versions:**
- Windows 11 24H2
- Windows 11 25H2
- Windows 11 Insider Preview (Build 26200+)
- Other recent builds may also be affected

This is a widespread issue across recent Windows updates/KB patches.

## The Solution

This script monitors your system and automatically cleans up Task Manager only when:
1. Task Manager is NOT actively in use (not in the foreground)
2. You haven't used your keyboard/mouse for 30+ seconds (system is idle)

This ensures Task Manager stays responsive while you're using it, but gets terminated when it's just lingering in the background.

## How to Use

### Step 1: Save the Script
Save `kill_taskmgr.ps1` on your Desktop.

### Step 2: Run the Script
Open PowerShell and run:
```powershell
powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\Desktop\kill_taskmgr.ps1"
```

Or simply navigate to Desktop in PowerShell and run:
```powershell
powershell -ExecutionPolicy Bypass -File ".\kill_taskmgr.ps1"
```

### Step 3: Keep Terminal Open
The terminal window must stay open while you want the script running. When you close the terminal, the script stops.

### Step 4: Test It
- Open Task Manager (Ctrl+Shift+Esc)
- Use it normally
- Close it
- After 30 seconds of system idle time, it will be automatically terminated

## What You'll See

When running, the script will display messages like:
- `Task Manager (PID: XXXX) is active in foreground` - while you're using it
- `Task Manager (PID: XXXX) in background` - when it's closed but still in memory
- `Killing Task Manager` - when it gets terminated after idle period

## How It Works

The script uses Windows API calls to:
1. **Detect the foreground window** - Knows when Task Manager is actively in use
2. **Monitor user activity** - Tracks keyboard/mouse input to detect idle time
3. **Process management** - Terminates Task Manager only when both conditions are met (background + idle)

## Important Notes

- ✅ **No personal information** is revealed in this script
- ✅ **Safe to share** - completely generic, works on any Windows system
- ✅ **Reversible** - just close the terminal to stop it
- ✅ **No admin rights needed** - regular user can run it
- ✅ **Open source** - examine the code, modify as needed
- ⏳ **Temporary fix** - Wait for Microsoft to release an official Windows patch

## Requirements

- Windows 11 (24H2, 25H2, or later)
- PowerShell 5.0 or higher (comes with Windows)
- No administrator privileges required

## Sharing This Script

You can safely share this script via email, GitHub, or any file transfer method. Recipients can:
1. Save it anywhere on their computer (Desktop, Documents, etc.)
2. Run it using the PowerShell command above
3. No modifications needed - it works as-is

## Status

⏳ **Temporary Workaround**: This is a temporary solution while waiting for an official Windows patch from Microsoft.

## Cleanup - When Windows is Patched

Once Microsoft releases a Windows Update that fixes the Task Manager background memory leak issue:

1. **Close the script** - Stop the PowerShell terminal running the script
2. **Delete the files** - You can safely delete the script and this repository
3. **Update Windows** - Install the official Windows patch
4. **Test Task Manager** - Verify that Task Manager no longer lingers in the background

You can monitor Windows updates on the [Microsoft Windows Release Health Dashboard](https://learn.microsoft.com/en-us/windows/release-health/) to see when this issue is fixed.

## Learning Resources

This script demonstrates:
- PowerShell scripting and automation
- Windows API P/Invoke calls in PowerShell
- Process monitoring and management
- System idle time detection
- Error handling and logging

## License

This project is open source and available for public use.

## Contributing

If you have improvements or find issues, feel free to open an issue or submit a pull request.

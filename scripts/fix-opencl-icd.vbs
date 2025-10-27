' OpenCL ICD Registry Fixer (NVIDIA / AMD)
Option Explicit

Dim shell, fso : Set shell = CreateObject("WScript.Shell") : Set fso = CreateObject("Scripting.FileSystemObject")

'--- Self-elevate to Admin (if not already) ---
If Not IsAdmin() Then
  Dim sh : Set sh = CreateObject("Shell.Application")
  sh.ShellExecute "wscript.exe", """" & WScript.ScriptFullName & """", "", "runas", 1
  WScript.Quit
End If

Dim windir, sys32, syswow64, driverstore, is64, archText
windir = shell.ExpandEnvironmentStrings("%WINDIR%")
sys32 = windir & "\System32"
syswow64 = windir & "\SysWOW64"
driverstore = sys32 & "\DriverStore\FileRepository"
is64 = (LCase(shell.ExpandEnvironmentStrings("%PROCESSOR_ARCHITECTURE%")) = "amd64") Or fso.FolderExists(syswow64)
If is64 Then
  archText = "64-bit"
Else
  archText = "32-bit"
End If

MsgBox "OpenCL ICD Registry Repair Utility" & vbCrLf & vbCrLf & _
       "This will register NVIDIA/AMD OpenCL ICDs so apps can find your GPU." & vbCrLf & _
       "Windows: " & archText & vbCrLf & vbCrLf & _
       "Click OK to continue.", vbInformation, "OpenCL ICD Fixer"

'--- Find ICD DLLs ---
Dim nv64, nv32, amd64, amd32
nv64 = FindNvidia64(sys32, driverstore)
If is64 Then nv32 = FindNvidia32(syswow64, driverstore)
amd64 = FindAmd64(sys32, driverstore)
If is64 Then amd32 = FindAmd32(syswow64, driverstore)

' If NVIDIA not found, offer manual paste
If nv64 = "" Then nv64 = InputBox("NVIDIA 64-bit ICD not auto-detected." & vbCrLf & _
                                  "Paste full path to nvopencl64.dll (or System32\nvopencl.dll):", "Manual Path")
If is64 And nv32 = "" Then nv32 = InputBox("NVIDIA 32-bit ICD not auto-detected." & vbCrLf & _
                                           "Paste full path to nvopencl32.dll (or SysWOW64\nvopencl.dll):", "Manual Path")
' AMD manual (optional)
If amd64 = "" Then
  Dim ansA : ansA = MsgBox("AMD 64-bit ICD not found automatically. Do you want to enter it manually?", vbYesNo+vbQuestion, "Optional")
  If ansA = vbYes Then amd64 = InputBox("Paste full path to AMD 64-bit ICD (amdocl64*.dll):", "Manual Path")
End If
If is64 And amd32 = "" Then
  Dim ansB : ansB = MsgBox("AMD 32-bit ICD not found automatically. Do you want to enter it manually?", vbYesNo+vbQuestion, "Optional")
  If ansB = vbYes Then amd32 = InputBox("Paste full path to AMD 32-bit ICD (amdocl*.dll):", "Manual Path")
End If

Dim summary
summary = "Detected paths:" & vbCrLf & _
          "  NVIDIA 64-bit: " & nv64 & vbCrLf & _
          "  NVIDIA 32-bit: " & nv32 & vbCrLf & _
          "  AMD    64-bit: " & amd64 & vbCrLf & _
          "  AMD    32-bit: " & amd32
MsgBox summary, vbInformation, "Detection Summary"

'--- Vendor choice ---
Dim choice
choice = InputBox("Register which vendor for OpenCL?" & vbCrLf & _
                  "[N] NVIDIA   [A] AMD   [B] Both   [C] Cancel", "Choose Vendor", "N")
choice = UCase(Trim(choice))
If choice = "" Or choice = "C" Then
  MsgBox "Cancelled.", vbInformation, "OpenCL ICD Fixer"
  WScript.Quit
End If

'--- Backup existing registry ---
BackupKey "HKLM\SOFTWARE\Khronos\OpenCL\Vendors", GetTempFile("OpenCL_Vendors_64.reg")
If is64 Then BackupKey "HKLM\SOFTWARE\WOW6432Node\Khronos\OpenCL\Vendors", GetTempFile("OpenCL_Vendors_32.reg")

'--- Ensure base keys exist ---
RunQuiet "reg add ""HKLM\SOFTWARE\Khronos\OpenCL\Vendors"" /f"
If is64 Then RunQuiet "reg add ""HKLM\SOFTWARE\WOW6432Node\Khronos\OpenCL\Vendors"" /f"

Dim wrote : wrote = False

'--- Register per selection ---
Select Case choice
  Case "N"
    If nv64 <> "" Then AddICD "HKLM\SOFTWARE\Khronos\OpenCL\Vendors", nv64 : wrote = True Else Warn "Missing NVIDIA 64-bit ICD path."
    If is64 Then
      If nv32 <> "" Then AddICD "HKLM\SOFTWARE\WOW6432Node\Khronos\OpenCL\Vendors", nv32 : wrote = True Else Warn "Missing NVIDIA 32-bit ICD path."
    End If

  Case "A"
    If amd64 <> "" Then AddICD "HKLM\SOFTWARE\Khronos\OpenCL\Vendors", amd64 : wrote = True Else Warn "Missing AMD 64-bit ICD."
    If is64 Then
      If amd32 <> "" Then AddICD "HKLM\SOFTWARE\WOW6432Node\Khronos\OpenCL\Vendors", amd32 : wrote = True Else Warn "Missing AMD 32-bit ICD."
    End If

  Case "B"
    If nv64 <> "" Then AddICD "HKLM\SOFTWARE\Khronos\OpenCL\Vendors", nv64 : wrote = True Else Warn "Missing NVIDIA 64-bit ICD."
    If is64 Then
      If nv32 <> "" Then AddICD "HKLM\SOFTWARE\WOW6432Node\Khronos\OpenCL\Vendors", nv32 : wrote = True Else Warn "Missing NVIDIA 32-bit ICD."
    End If
    If amd64 <> "" Then AddICD "HKLM\SOFTWARE\Khronos\OpenCL\Vendors", amd64 : wrote = True Else Warn "Missing AMD 64-bit ICD."
    If is64 Then
      If amd32 <> "" Then AddICD "HKLM\SOFTWARE\WOW6432Node\Khronos\OpenCL\Vendors", amd32 : wrote = True Else Warn "Missing AMD 32-bit ICD."
    End If

  Case Else
    MsgBox "Invalid choice.", vbExclamation, "OpenCL ICD Fixer"
End Select

'--- Show final registry ---
Dim finalMsg
finalMsg = "Final Khronos vendor keys: " & vbCrLf & vbCrLf & _
           QueryKey("HKLM\SOFTWARE\Khronos\OpenCL\Vendors")
If is64 Then finalMsg = finalMsg & vbCrLf & QueryKey("HKLM\SOFTWARE\WOW6432Node\Khronos\OpenCL\Vendors")
MsgBox finalMsg, vbInformation, "OpenCL ICD Fixer"

If wrote Then
  MsgBox "Done. A reboot is recommended." & vbCrLf & vbCrLf & _
         "After reboot, run clinfo or your miner again.", vbInformation, "OpenCL ICD Fixer"
Else
  MsgBox "Nothing was written because no valid paths were provided.", vbExclamation, "OpenCL ICD Fixer"
End If

WScript.Quit

'------------------ Helpers ------------------

Function IsAdmin()
  On Error Resume Next
  shell.RegWrite "HKLM\SOFTWARE\OpenCL_ICD_Fixer\Test", 1, "REG_DWORD"
  If Err.Number <> 0 Then
    IsAdmin = False : Err.Clear
  Else
    IsAdmin = True
    shell.RegDelete "HKLM\SOFTWARE\OpenCL_ICD_Fixer\Test"
  End If
  On Error GoTo 0
End Function

Sub Warn(msg) : MsgBox msg, vbExclamation, "OpenCL ICD Fixer" : End Sub

Function GetTempFile(name)
  GetTempFile = shell.ExpandEnvironmentStrings("%TEMP%") & "\" & name
End Function

Sub BackupKey(regpath, outfile)
  RunQuiet "reg export """ & regpath & """ """ & outfile & """ /y"
End Sub

Sub AddICD(regpath, dllpath)
  If dllpath = "" Then Exit Sub
  If Not fso.FileExists(dllpath) Then
    Warn "Path does not exist: " & dllpath
    Exit Sub
  End If
  RunQuiet "reg add """ & regpath & """ /v """ & dllpath & """ /t REG_DWORD /d 0 /f"
End Sub

Function QueryKey(regpath)
  Dim tmp, cmd, out
  tmp = GetTempFile("opencl_icd_query.txt")
  cmd = "cmd /c reg query """ & regpath & """ > """ & tmp & """ 2>&1"
  RunQuiet cmd
  If fso.FileExists(tmp) Then
    Dim ts : Set ts = fso.OpenTextFile(tmp, 1)
    out = ts.ReadAll
    ts.Close
    fso.DeleteFile tmp
  Else
    out = "(no entries)"
  End If
  QueryKey = out
End Function

Sub RunQuiet(cmd)
  Dim exec : Set exec = shell.Exec(cmd)
  Do While exec.Status = 0
    WScript.Sleep 50
  Loop
End Sub

Function FindNvidia64(sys32Path, driverStorePath)
  If fso.FileExists(sys32Path & "\nvopencl.dll") Then
    FindNvidia64 = sys32Path & "\nvopencl.dll" : Exit Function
  End If
  FindNvidia64 = FindInDriverStore(driverStorePath, Array("nvopencl64.dll","nvopencl.dll"))
End Function

Function FindNvidia32(syswowPath, driverStorePath)
  If fso.FileExists(syswowPath & "\nvopencl.dll") Then
    FindNvidia32 = syswowPath & "\nvopencl.dll" : Exit Function
  End If
  FindNvidia32 = FindInDriverStore(driverStorePath, Array("nvopencl32.dll","nvopencl.dll"))
End Function

Function FindAmd64(sys32Path, driverStorePath)
  If fso.FileExists(sys32Path & "\amdocl64.dll") Then
    FindAmd64 = sys32Path & "\amdocl64.dll" : Exit Function
  End If
  If fso.FileExists(sys32Path & "\amdocl12cl64.dll") Then
    FindAmd64 = sys32Path & "\amdocl12cl64.dll" : Exit Function
  End If
  FindAmd64 = FindInDriverStore(driverStorePath, Array("amdocl12cl64.dll","amdocl64.dll"))
End Function

Function FindAmd32(syswowPath, driverStorePath)
  If fso.FileExists(syswowPath & "\amdocl.dll") Then
    FindAmd32 = syswowPath & "\amdocl.dll" : Exit Function
  End If
  If fso.FileExists(syswowPath & "\amdocl12cl.dll") Then
    FindAmd32 = syswowPath & "\amdocl12cl.dll" : Exit Function
  End If
  FindAmd32 = FindInDriverStore(driverStorePath, Array("amdocl12cl.dll","amdocl.dll"))
End Function

Function FindInDriverStore(root, names)
  On Error Resume Next
  Dim folder, subf, n, p
  If Not fso.FolderExists(root) Then Exit Function
  Set folder = fso.GetFolder(root)
  For Each subf In folder.SubFolders
    For Each n In names
      p = subf.Path & "\" & n
      If fso.FileExists(p) Then FindInDriverStore = p : Exit Function
    Next
  Next
  On Error GoTo 0
  FindInDriverStore = ""
End Function

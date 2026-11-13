; Throwaway per-user installer for the toast-buttons spike (A-1). Unsigned on purpose.
Unicode true
Name "Toast Spike"
OutFile "out\ToastSpikeSetup.exe"
RequestExecutionLevel user
InstallDir "$LOCALAPPDATA\Programs\ToastSpike"

Page directory
Page instfiles
UninstPage uninstConfirm
UninstPage instfiles

Section "Install"
  SetShellVarContext current
  SetOutPath "$INSTDIR"
  File /r "out\publish\*.*"
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  CreateShortcut "$SMPROGRAMS\Toast Spike.lnk" "$INSTDIR\ToastSpike.exe"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\ToastSpike" "DisplayName" "Toast Spike"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\ToastSpike" "UninstallString" '"$INSTDIR\Uninstall.exe"'
SectionEnd

Function .onInstSuccess
  Exec '"$INSTDIR\ToastSpike.exe"'
FunctionEnd

Section "Uninstall"
  SetShellVarContext current
  Delete "$SMPROGRAMS\Toast Spike.lnk"
  RMDir /r "$INSTDIR"
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\ToastSpike"
  DeleteRegKey HKCU "Software\Classes\AppUserModelId\MoveReminder.ToastSpike"
SectionEnd

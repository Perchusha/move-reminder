; The per-user installer of move-reminder (ADR-0002). Unsigned on purpose.
;
; scripts/build compiles it with makensis and these defines:
;   VERSION       x.y.z
;   OUT_FILE      the installer to write
;   FILES_DIR     the folder with install-files.nsh and uninstall-files.nsh, which
;                 scripts/build writes from the publish folder, one line per file
;   LICENSE_FILE  the project's LICENSE
;   NOTICES_FILE  THIRD-PARTY-NOTICES.txt, with the .NET runtime's notices appended
;   ICON_FILE     the app's icon, src/MoveReminder.App/Resources/move-reminder.ico,
;                 for the installer, the uninstaller and the Start menu shortcut
;
; It installs without administrator rights (no UAC prompt) into the fixed folder
; %LOCALAPPDATA%\Programs\move-reminder and offers no choice of folder. The
; uninstaller deletes the files the installer put there, one by one, and the Start
; menu shortcut; anything else in the folder, and %APPDATA%\move-reminder with the
; settings (ADR-0001), stays.

!ifndef VERSION | OUT_FILE | FILES_DIR | LICENSE_FILE | NOTICES_FILE | ICON_FILE
  !error "Build the installer with scripts/build, which passes VERSION, OUT_FILE, FILES_DIR, LICENSE_FILE, NOTICES_FILE and ICON_FILE."
!endif

!define PRODUCT "move-reminder"
!define EXE "MoveReminder.exe"
!define SHORTCUT "$SMPROGRAMS\${PRODUCT}.lnk"
!define UNINSTALL_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}"

Unicode true
ManifestDPIAware true
; zlib only: the stub's licence is then zlib/libpng alone (docs/SPEC.md, Dependency licences).
SetCompressor zlib
RequestExecutionLevel user
Name "${PRODUCT}"
OutFile "${OUT_FILE}"
; The app's own icon, the one MoveReminder.exe carries, not the NSIS default.
Icon "${ICON_FILE}"
UninstallIcon "${ICON_FILE}"
InstallDir "$LOCALAPPDATA\Programs\${PRODUCT}"
ShowInstDetails show
ShowUninstDetails show

LoadLanguageFile "${NSISDIR}\Contrib\Language files\Russian.nlf"

VIProductVersion "${VERSION}.0"
VIAddVersionKey /LANG=1049 "ProductName" "${PRODUCT}"
VIAddVersionKey /LANG=1049 "ProductVersion" "${VERSION}"
VIAddVersionKey /LANG=1049 "FileVersion" "${VERSION}"
VIAddVersionKey /LANG=1049 "FileDescription" "${PRODUCT} setup"
VIAddVersionKey /LANG=1049 "LegalCopyright" "Copyright (c) 2026 Anton Perch, MIT License"

; No directory page: the folder is fixed.
Page instfiles
UninstPage uninstConfirm
UninstPage instfiles

Function .onInit
  SetShellVarContext current
  ; The folder is fixed even when /D= is given on the command line.
  StrCpy $INSTDIR "$LOCALAPPDATA\Programs\${PRODUCT}"
FunctionEnd

Section "Install"
  SetShellVarContext current
  !include "${FILES_DIR}\install-files.nsh"
  SetOutPath "$INSTDIR"
  File "/oname=LICENSE.txt" "${LICENSE_FILE}"
  File "/oname=THIRD-PARTY-NOTICES.txt" "${NOTICES_FILE}"
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  ; The shortcut's icon is the one MoveReminder.exe carries, the app's own.
  CreateShortcut "${SHORTCUT}" "$INSTDIR\${EXE}" "" "$INSTDIR\${EXE}" 0
  WriteRegStr HKCU "${UNINSTALL_KEY}" "DisplayName" "${PRODUCT}"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "DisplayVersion" "${VERSION}"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "Publisher" "Anton Perch"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "DisplayIcon" "$INSTDIR\${EXE}"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "UninstallString" '"$INSTDIR\Uninstall.exe"'
  WriteRegStr HKCU "${UNINSTALL_KEY}" "QuietUninstallString" '"$INSTDIR\Uninstall.exe" /S'
  WriteRegDWORD HKCU "${UNINSTALL_KEY}" "NoModify" 1
  WriteRegDWORD HKCU "${UNINSTALL_KEY}" "NoRepair" 1
SectionEnd

Function .onInstSuccess
  ; A silent install (/S, as in scripts/test-installer) does not start the app.
  IfSilent +2
  Exec '"$INSTDIR\${EXE}"'
FunctionEnd

Function un.onInit
  SetShellVarContext current
FunctionEnd

Section "Uninstall"
  SetShellVarContext current
  Delete "${SHORTCUT}"
  !include "${FILES_DIR}\uninstall-files.nsh"
  Delete "$INSTDIR\LICENSE.txt"
  Delete "$INSTDIR\THIRD-PARTY-NOTICES.txt"
  Delete "$INSTDIR\Uninstall.exe"
  ; Not /r: the folder goes only when nothing else is left in it.
  RMDir "$INSTDIR"
  DeleteRegKey HKCU "${UNINSTALL_KEY}"
SectionEnd

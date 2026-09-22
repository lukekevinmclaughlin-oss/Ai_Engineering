Unicode true
RequestExecutionLevel user
SetCompressor /SOLID lzma
!include "MUI2.nsh"
!define PRODUCT_NAME "AI Engineering"
!define PRODUCT_VERSION "1.0.0"
!define UNINSTALL_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\AI Engineering"
Name "${PRODUCT_NAME}"
OutFile "..\release\AI Engineering-1.0.0-Windows-x64-Setup.exe"
InstallDir "$LOCALAPPDATA\Programs\AI Engineering"
InstallDirRegKey HKCU "Software\Luke McLaughlin\AI Engineering" "InstallLocation"
Icon "icon.ico"
UninstallIcon "icon.ico"
BrandingText "AI Engineering for Windows 11"
ShowInstDetails show
ShowUninstDetails show
VIProductVersion "1.0.0.1"
VIAddVersionKey /LANG=1033 "ProductName" "AI Engineering"
VIAddVersionKey /LANG=1033 "CompanyName" "Luke McLaughlin"
VIAddVersionKey /LANG=1033 "FileDescription" "AI engineering courses, projects and tutoring for Windows"
VIAddVersionKey /LANG=1033 "FileVersion" "1.0.0"
VIAddVersionKey /LANG=1033 "ProductVersion" "1.0.0"
VIAddVersionKey /LANG=1033 "LegalCopyright" "Copyright Luke McLaughlin"
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "English"
Section "Install"
  SetShellVarContext current
  SetOutPath "$INSTDIR"
  File /r "..\release\win-unpacked\*.*"
  CreateDirectory "$SMPROGRAMS\AI Engineering"
  CreateShortCut "$SMPROGRAMS\AI Engineering\AI Engineering.lnk" "$INSTDIR\AI Engineering.exe"
  CreateShortCut "$DESKTOP\AI Engineering.lnk" "$INSTDIR\AI Engineering.exe"
  WriteUninstaller "$INSTDIR\Uninstall AI Engineering.exe"
  WriteRegStr HKCU "Software\Luke McLaughlin\AI Engineering" "InstallLocation" "$INSTDIR"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "DisplayName" "AI Engineering"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "DisplayVersion" "1.0.0"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "Publisher" "Luke McLaughlin"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "DisplayIcon" "$INSTDIR\AI Engineering.exe"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "UninstallString" '"$INSTDIR\Uninstall AI Engineering.exe"'
  WriteRegStr HKCU "${UNINSTALL_KEY}" "QuietUninstallString" '"$INSTDIR\Uninstall AI Engineering.exe" /S'
  WriteRegDWORD HKCU "${UNINSTALL_KEY}" "NoModify" 1
  WriteRegDWORD HKCU "${UNINSTALL_KEY}" "NoRepair" 1
SectionEnd
Section "Uninstall"
  SetShellVarContext current
  Delete "$DESKTOP\AI Engineering.lnk"
  Delete "$SMPROGRAMS\AI Engineering\AI Engineering.lnk"
  RMDir "$SMPROGRAMS\AI Engineering"
  DeleteRegKey HKCU "${UNINSTALL_KEY}"
  DeleteRegKey HKCU "Software\Luke McLaughlin\AI Engineering"
  !include "uninstall-files.nsh"
  Delete "$INSTDIR\Uninstall AI Engineering.exe"
  RMDir "$INSTDIR"
SectionEnd

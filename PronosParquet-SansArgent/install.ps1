$ErrorActionPreference = 'Stop'
try {
  $src  = Split-Path -Parent $MyInvocation.MyCommand.Path
  $dest = Join-Path $env:LOCALAPPDATA 'PronosParquetSansArgent'
  New-Item -ItemType Directory -Force -Path $dest | Out-Null
  Copy-Item (Join-Path $src 'app.html')  $dest -Force
  Copy-Item (Join-Path $src 'icone.ico') $dest -Force
  Copy-Item (Join-Path $src 'desinstaller.ps1') $dest -Force
  $html = Join-Path $dest 'app.html'
  $ico  = Join-Path $dest 'icone.ico'
  $url  = ([Uri]$html).AbsoluteUri

  function Find-Browser($exe, $fallbacks) {
    foreach ($root in 'HKCU:', 'HKLM:') {
      $k = "$root\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\$exe"
      if (Test-Path $k) { $p = (Get-ItemProperty $k).'(default)'; if ($p -and (Test-Path $p)) { return $p } }
    }
    foreach ($f in $fallbacks) { if ($f -and (Test-Path $f)) { return $f } }
    return $null
  }
  $browser = Find-Browser 'msedge.exe' @("${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe", "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe")
  if (-not $browser) { $browser = Find-Browser 'chrome.exe' @("$env:ProgramFiles\Google\Chrome\Application\chrome.exe", "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe", "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe") }

  $shell = New-Object -ComObject WScript.Shell
  $places = @([Environment]::GetFolderPath('Desktop'), [Environment]::GetFolderPath('Programs'))
  foreach ($dir in $places) {
    $lnk = $shell.CreateShortcut((Join-Path $dir 'Pronos Parquet (sans argent).lnk'))
    if ($browser) { $lnk.TargetPath = $browser; $lnk.Arguments = "--app=`"$url`"" }
    else { $lnk.TargetPath = $html }
    $lnk.IconLocation = "$ico,0"
    $lnk.WorkingDirectory = $dest
    $lnk.Description = 'Pronos Parquet - suivre la NBA sans parier d''argent'
    $lnk.Save()
  }

  if ($browser) { Start-Process $browser "--app=`"$url`"" } else { Start-Process $html }
  Add-Type -AssemblyName System.Windows.Forms
  [System.Windows.Forms.MessageBox]::Show("Pronos Parquet (sans argent) est installé !`n`nTu le trouves sur ton bureau et dans le menu Démarrer.`n`nBesoin d'aide pour arrêter les paris ? Joueurs Info Service : 09 74 75 13 13 (anonyme et gratuit, tous les jours de 8h à 2h).", 'Pronos Parquet') | Out-Null
} catch {
  Add-Type -AssemblyName System.Windows.Forms
  [System.Windows.Forms.MessageBox]::Show("L'installation a échoué :`n$($_.Exception.Message)", 'Pronos Parquet') | Out-Null
}

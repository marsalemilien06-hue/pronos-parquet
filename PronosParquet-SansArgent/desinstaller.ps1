$ErrorActionPreference = 'SilentlyContinue'
Add-Type -AssemblyName System.Windows.Forms
$r = [System.Windows.Forms.MessageBox]::Show("Désinstaller Pronos Parquet (sans argent) ?", 'Pronos Parquet', 'YesNo')
if ($r -ne 'Yes') { exit }
foreach ($dir in @([Environment]::GetFolderPath('Desktop'), [Environment]::GetFolderPath('Programs'))) {
  Remove-Item (Join-Path $dir 'Pronos Parquet (sans argent).lnk') -Force
}
Remove-Item (Join-Path $env:LOCALAPPDATA 'PronosParquetSansArgent') -Recurse -Force
[System.Windows.Forms.MessageBox]::Show("Pronos Parquet (sans argent) a été désinstallé.", 'Pronos Parquet') | Out-Null

# WinQuick - Big catalog winget installer (GUI + CLI)
# Usage:
#   .\WinQuick.ps1                      -> open GUI
#   .\WinQuick.ps1 -Install "OBS Studio","Google Chrome" -> no GUI

param([string[]]$Install)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Ensure-Winget {
  try { winget -v *> $null; return $true } catch { return $false }
}
if (-not (Ensure-Winget)) {
  [System.Windows.Forms.MessageBox]::Show("winget is not available. Update to latest Windows 10/11 or install App Installer from Microsoft Store.","winget missing") | Out-Null
  exit 1
}

# ================= Catalog (DisplayName = Winget ID) =================
$Catalog = [ordered]@{
  # Browsers
  "Google Chrome"                    = "Google.Chrome"
  "Microsoft Edge"                   = "Microsoft.Edge"
  "Mozilla Firefox"                  = "Mozilla.Firefox"
  "Brave Browser"                    = "Brave.Brave"
  "Vivaldi Browser"                  = "VivaldiTechnologies.Vivaldi"
  "Opera"                            = "Opera.Opera"

  # Dev & Terminals
  "Visual Studio Code"               = "Microsoft.VisualStudioCode"
  "Visual Studio 2022 Community"     = "Microsoft.VisualStudio.2022.Community"
  "Git"                               = "Git.Git"
  "GitHub Desktop"                   = "GitHub.GitHubDesktop"
  "Node.js LTS"                      = "OpenJS.NodeJS.LTS"
  "Python 3"                         = "Python.Python.3.12"
  "Go"                               = "GoLang.Go"
  "OpenJDK 17 (Temurin)"             = "EclipseAdoptium.Temurin.17.JDK"
  "JetBrains Toolbox"                = "JetBrains.Toolbox"
  "Docker Desktop"                   = "Docker.DockerDesktop"
  "Postman"                          = "Postman.Postman"
  "DBeaver CE"                       = "DBeaverCorp.DBeaverCE"
  "MySQL Workbench"                  = "Oracle.MySQLWorkbench"
  "DB Browser for SQLite"            = "sqlitebrowser.sqlitebrowser"
  "Windows Terminal"                 = "Microsoft.WindowsTerminal"
  "PowerShell 7"                     = "Microsoft.PowerShell"

  # Utilities / File tools
  "7-Zip"                            = "7zip.7zip"
  "WinRAR"                           = "RARLab.WinRAR"
  "PeaZip"                           = "Giorgiotani.Peazip"
  "Everything Search"                = "voidtools.Everything"
  "Rufus"                            = "Rufus.Rufus"
  "balenaEtcher"                     = "Balena.Etcher"
  "TeraCopy"                         = "Codesector.TeraCopy"
  "WinSCP"                           = "WinSCP.WinSCP"
  "FileZilla"                        = "FileZilla.FileZilla"
  "PuTTY"                            = "PuTTY.PuTTY"
  "ShareX"                           = "ShareX.ShareX"
  "Greenshot"                        = "Greenshot.Greenshot"
  "Lightshot"                        = "Skillbrains.Lightshot"
  "ScreenToGif"                      = "NickeManarin.ScreenToGif"
  "Microsoft PowerToys"              = "Microsoft.PowerToys"

  # Cloud & Notes
  "Google Drive"                     = "Google.Drive"
  "Dropbox"                          = "Dropbox.Dropbox"
  "OneDrive"                         = "Microsoft.OneDrive"
  "MEGASync"                         = "Mega.MEGASync"
  "Notion"                           = "Notion.Notion"
  "Obsidian"                         = "Obsidian.Obsidian"
  "Evernote"                         = "Evernote.Evernote"
  "Typora"                           = "Typora.Typora"

  # Office / PDF
  "LibreOffice"                      = "TheDocumentFoundation.LibreOffice"
  "ONLYOFFICE"                       = "ONLYOFFICE.DesktopEditors"
  "Adobe Acrobat Reader"             = "Adobe.Acrobat.Reader.64-bit"
  "Foxit Reader"                     = "Foxit.FoxitReader"
  "Notepad++"                        = "Notepad++.Notepad++"
  "Sublime Text 4"                   = "SublimeText.SublimeText.4"

  # Media
  "VLC media player"                 = "VideoLAN.VLC"
  "mpv.net"                          = "mpv.net-project.mpv.net"
  "PotPlayer"                        = "Daum.PotPlayer"
  "K-Lite Codec Pack Standard"       = "CodecGuide.K-LiteCodecPack.Standard"
  "HandBrake"                        = "HandBrake.HandBrake"
  "Spotify"                          = "Spotify.Spotify"
  "foobar2000"                       = "PeterPawlowski.foobar2000"

  # Design / Photo / Video / Audio
  "Paint.NET"                        = "dotPDNLLC.paintdotnet"
  "GIMP"                             = "GIMP.GIMP"
  "Inkscape"                         = "Inkscape.Inkscape"
  "Krita"                            = "KDE.Krita"
  "Blender"                          = "BlenderFoundation.Blender"
  "DaVinci Resolve"                  = "BlackmagicDesign.DaVinciResolve"
  "OpenShot"                         = "OpenShot.OpenShot"
  "Audacity"                         = "Audacity.Audacity"

  # Communication
  "Discord"                          = "Discord.Discord"
  "Telegram Desktop"                 = "Telegram.TelegramDesktop"
  "Slack"                            = "SlackTechnologies.Slack"
  "Zoom"                             = "Zoom.Zoom"
  "Microsoft Teams"                  = "Microsoft.Teams"
  "WhatsApp"                         = "WhatsApp.WhatsApp"
  "Signal"                           = "OpenWhisperSystems.Signal"

  # Gaming
  "Steam"                            = "Valve.Steam"
  "Epic Games Launcher"              = "EpicGames.EpicGamesLauncher"
  "GOG Galaxy"                       = "GOG.Galaxy"

  # Security / VPN / Passwords
  "WireGuard"                        = "WireGuard.WireGuard"
  "Bitwarden"                        = "Bitwarden.Bitwarden"
  "1Password"                        = "1Password.1Password"
  "KeePass"                          = "DominikReichl.KeePass"

  # System info
  "CPU-Z"                            = "CPUID.CPU-Z"
  "GPU-Z"                            = "TechPowerUp.GPU-Z"
  "HWMonitor"                        = "CPUID.HWMonitor"

  # Streaming / Recording
  "OBS Studio"                       = "OBSProject.OBSStudio"
}

# ================= Core installer =================
function Install-App {
  param([Parameter(Mandatory=$true)][string]$Name)
  if (-not $Catalog.Contains($Name)) { throw "App '$Name' not in catalog." }
  $id = $Catalog[$Name]
  $args = @(
    "install","--id",$id,"-e",
    "--accept-package-agreements","--accept-source-agreements","--silent"
  )
  $p = Start-Process -FilePath "winget" -ArgumentList $args -Wait -PassThru -WindowStyle Hidden
  return $p.ExitCode
}

# ================= CLI mode (no GUI) =================
if ($Install -and $Install.Count -gt 0) {
  foreach ($app in $Install) {
    if (-not $Catalog.Contains($app)) { Write-Host "Skip: $app (not in catalog)"; continue }
    Write-Host "Installing: $app ..."
    $code = Install-App -Name $app
    if ($code -eq 0) { Write-Host "OK: $app" -ForegroundColor Green } else { Write-Host "ERR($code): $app" -ForegroundColor Red }
  }
  exit
}

# ================= GUI =================
$form = New-Object System.Windows.Forms.Form
$form.Text = "WinQuick - Install apps"
$form.Size = New-Object System.Drawing.Size(820,560)
$form.StartPosition = "CenterScreen"

$lbl = New-Object System.Windows.Forms.Label
$lbl.Text = "Search, tick apps, then Install"
$lbl.AutoSize = $true
$lbl.Location = New-Object System.Drawing.Point(12,12)
$form.Controls.Add($lbl)

$txtSearch = New-Object System.Windows.Forms.TextBox
$txtSearch.PlaceholderText = "Search..."
$txtSearch.Location = New-Object System.Drawing.Point(12,35)
$txtSearch.Size = New-Object System.Drawing.Size(360,28)
$form.Controls.Add($txtSearch)

$chkAll = New-Object System.Windows.Forms.CheckBox
$chkAll.Text = "Select all"
$chkAll.AutoSize = $true
$chkAll.Location = New-Object System.Drawing.Point(390,38)
$form.Controls.Add($chkAll)

$clb = New-Object System.Windows.Forms.CheckedListBox
$clb.Location = New-Object System.Drawing.Point(12,70)
$clb.Size = New-Object System.Drawing.Size(380,400)
$clb.CheckOnClick = $true
$form.Controls.Add($clb)

$btnInstall = New-Object System.Windows.Forms.Button
$btnInstall.Text = "Install selected"
$btnInstall.Location = New-Object System.Drawing.Point(12,480)
$btnInstall.Size = New-Object System.Drawing.Size(200,32)
$form.Controls.Add($btnInstall)

$txtLog = New-Object System.Windows.Forms.TextBox
$txtLog.Location = New-Object System.Drawing.Point(410,70)
$txtLog.Size = New-Object System.Drawing.Size(380,400)
$txtLog.Multiline = $true
$txtLog.ScrollBars = "Vertical"
$txtLog.ReadOnly = $true
$form.Controls.Add($txtLog)

$lblLog = New-Object System.Windows.Forms.Label
$lblLog.Text = "Log"
$lblLog.AutoSize = $true
$lblLog.Location = New-Object System.Drawing.Point(410,48)
$form.Controls.Add($lblLog)

function Append-Log([string]$line) {
  $ts = (Get-Date).ToString("HH:mm:ss")
  $txtLog.AppendText("[$ts] $line`r`n")
}

function Populate-List([string]$filter) {
  $clb.Items.Clear()
  $items = $Catalog.Keys
  if ($filter -and $filter.Trim().Length -gt 0) {
    $f = $filter.Trim().ToLower()
    $items = $items | Where-Object { $_.ToLower().Contains($f) }
  }
  foreach ($k in $items) { [void]$clb.Items.Add($k) }
}
Populate-List ""

$txtSearch.Add_TextChanged({ Populate-List $txtSearch.Text })

$chkAll.Add_CheckedChanged({
  for ($i=0; $i -lt $clb.Items.Count; $i++) { $clb.SetItemChecked($i, $chkAll.Checked) }
})

$btnInstall.Add_Click({
  $selected = @()
  foreach ($i in 0..($clb.Items.Count-1)) {
    if ($clb.GetItemChecked($i)) { $selected += [string]$clb.Items[$i] }
  }
  if ($selected.Count -eq 0) {
    [System.Windows.Forms.MessageBox]::Show("Please select at least one app.","No selection") | Out-Null
    return
  }

  $btnInstall.Enabled = $false
  foreach ($app in $selected) {
    Append-Log "Installing: $app"
    try {
      $code = Install-App -Name $app
      if ($code -eq 0) { Append-Log "OK: $app" } else { Append-Log "ERROR ($code): $app" }
    } catch {
      Append-Log "ERROR: $($_.Exception.Message)"
    }
  }
  Append-Log "All tasks done."
  $btnInstall.Enabled = $true
})

[void]$form.ShowDialog()

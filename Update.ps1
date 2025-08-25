Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Get-UpgradableApps {
    $raw = winget upgrade --accept-source-agreements | Out-String
    $lines = $raw -split "`r?`n" | Where-Object { $_ -match '\S' -and -not ($_ -match 'Name\s+Id\s+Version') -and -not ($_ -match '^---') }
    $apps = @()
    foreach ($line in $lines) {
        $parts = $line -split '\s{2,}'
        if ($parts.Count -ge 3) {
            $apps += [PSCustomObject]@{
                Name      = $parts[0].Trim()
                Id        = $parts[1].Trim()
                Version   = $parts[2].Trim()
                Available = if ($parts.Count -ge 4) { $parts[3].Trim() } else { "" }
            }
        }
    }
    return $apps
}

function Update-App {
    param([string]$id, [string]$name)
    try {
        Start-Process winget -ArgumentList @("upgrade","--id",$id,"-e","--accept-source-agreements","--silent") -Wait
        Append-Log "Updated: $name"
    } catch {
        Append-Log "Failed: $name"
    }
}

$form = New-Object Windows.Forms.Form
$form.Text = "Update"
$form.Size = New-Object Drawing.Size(820,560)
$form.StartPosition = "CenterScreen"

$btnRefresh = New-Object Windows.Forms.Button
$btnRefresh.Text = "Check Updates"
$btnRefresh.Location = New-Object Drawing.Point(10,10)
$btnRefresh.Size = New-Object Drawing.Size(120,30)
$form.Controls.Add($btnRefresh)

$clb = New-Object Windows.Forms.CheckedListBox
$clb.Location = New-Object Drawing.Point(10,50)
$clb.Size = New-Object Drawing.Size(500,450)
$clb.CheckOnClick = $true
$form.Controls.Add($clb)

$btnUpdate = New-Object Windows.Forms.Button
$btnUpdate.Text = "Update Selected"
$btnUpdate.Location = New-Object Drawing.Point(10,510)
$btnUpdate.Size = New-Object Drawing.Size(200,30)
$form.Controls.Add($btnUpdate)

$log = New-Object Windows.Forms.TextBox
$log.Location = New-Object Drawing.Point(520,50)
$log.Size = New-Object Drawing.Size(280,450)
$log.Multiline = $true
$log.ScrollBars = "Vertical"
$form.Controls.Add($log)

function Append-Log([string]$line) {
    $ts = (Get-Date).ToString("HH:mm:ss")
    $log.AppendText("[$ts] $line`r`n")
}

function Refresh-Apps {
    $clb.Items.Clear()
    $apps = Get-UpgradableApps
    if ($apps.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("All apps are up to date!") | Out-Null
        return
    }
    foreach ($a in $apps) {
        $display = "{0} (Installed: {1} → {2})" -f $a.Name,$a.Version,$a.Available
        $idx = $clb.Items.Add($display)
        $clb.Items[$idx].Tag = $a
    }
}

$btnRefresh.Add_Click({ Refresh-Apps })
$btnUpdate.Add_Click({
    for ($i=0; $i -lt $clb.Items.Count; $i++) {
        if ($clb.GetItemChecked($i)) {
            $app = $clb.Items[$i].Tag
            Update-App -id $app.Id -name $app.Name
        }
    }
})

Refresh-Apps
[void]$form.ShowDialog()

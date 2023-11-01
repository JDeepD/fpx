# Initialize an array of key-value pairs in one go
$ProxyList = @(
    [PSCustomObject]@{
        Name = "Hostel-9"
        Host = "172.16.2.11"
        Port = "3128"
    },

    [PSCustomObject]@{
        Name = "Library/Labs"
        Host = "172.16.199.20"
        Port = "8080"
    },

    [PSCustomObject]@{
        Name = "GH-2/3/BH-6"
        Host = "103.200.80.229"
        Port = "3128"
    },
    [PSCustomObject]@{
        Name = "Hostels"
        Host = "172.16.199.40"
        Port = "8080"
    }
)
function setproxy {
    param (
        [string]$proxyserver
    )
    git config --global http.proxy $proxyserver
    git config --global https.proxy $proxyserver
    npm config set proxy $proxyserver
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name 'ProxyServer' -Value $proxyserver
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name 'ProxyEnable' -Value 1
    # [System.Environment]::SetEnvironmentVariable('http_proxy',$proxyserver, [System.EnvironmentVariableTarget]::Machine)
	# [System.Environment]::SetEnvironmentVariable('https_proxy',$proxyserver, [System.EnvironmentVariableTarget]::Machine)


}

function unsetproxy {
    git config --global --unset http.proxy
    git config --global --unset https.proxy
    npm config -g rm proxy
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name 'ProxyEnable' -Value 0
    # [System.Environment]::SetEnvironmentVariable('http_proxy','',[System.EnvironmentVariableTarget]::Machine)
	# [System.Environment]::SetEnvironmentVariable('https_proxy','',[System.EnvironmentVariableTarget]::Machine)
}

function updateproxy {
    $isProxyEnabled = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name 'ProxyEnable'
    $currentproxy = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name 'ProxyServer'
    if($isProxyEnabled.ProxyEnable){
        $info.Text = "Current Proxy: " + $currentproxy.ProxyServer
    }else{
        $info.Text = "Proxy is disabled"
    }
}

Add-Type -assembly System.Windows.Forms

$FormMain = New-Object System.Windows.Forms.Form
$FormMain.Text ='FPX : A Fast Proxy Manager'
$FormMain.Width = 400
$FormMain.Height = 200
$FormMain.AutoSize = $false

$info = New-Object Windows.Forms.Label
$info.Location = New-Object Drawing.Point(20, 140)
$info.Font = New-Object Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)  # Set font size to 14
updateproxy
$info.AutoSize = $true
$FormMain.Controls.Add($info)

$label = New-Object Windows.Forms.Label
$label.Location = New-Object Drawing.Point(20, 20)
$label.Text = "Select a Proxy:"
$label.Font = New-Object Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)  # Set font size to 14
$label.AutoSize = $true
$FormMain.Controls.Add($label)

$comboBox = New-Object Windows.Forms.ComboBox
$comboBox.Location = New-Object Drawing.Point(20, 50)
$comboBox.Width = 350
$comboBox.Font = New-Object Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Regular)  # Set font size to 12
$comboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList

foreach ($proxy in $ProxyList) {
    $proxyserver = "http://" + $proxy.Host + ":" + $proxy.Port 
    $comboBox.Items.Add($proxyserver + " (" + $proxy.Name + ")")
}
$comboBox.Items.Add("Unset All Proxy (Mobile Data)")

$comboBox.SelectedIndex = 0
$FormMain.Controls.Add($comboBox)


$button = New-Object Windows.Forms.Button
$button.Location = New-Object Drawing.Point(20, 110)
$button.Text = "Set Proxy"
$button.Add_Click({
    $selectedOption = $comboBox.SelectedIndex
    $proxyserver = "http://" + $ProxyList[$selectedOption].Host + ":" + $ProxyList[$selectedOption].Port
    if($selectedOption -eq $($comboBox.Items.Count - 1)){
        unsetproxy
    }else{
        setproxy $proxyserver
    }
    updateproxy
    $FormMain.Refresh()
})
$FormMain.Controls.Add($button)


$FormMain.ShowDialog()

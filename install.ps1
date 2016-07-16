try {
    $url="https://github.com/arleyschrock/electron-browser/archive/master.zip"
    $node= ""
    $npm = "https://nodejs.org/download/release/npm/npm-1.4.9.zip"
    if ([System.IntPtr]::Size -eq 4) { 
        $node = "https://nodejs.org/download/release/latest/win-x86/node.exe"
     } 
     else{ 
         $node = "https://nodejs.org/download/release/latest/win-x64/node.exe"
    }
function Download-File {
param (
  [string]$url,
  [string]$file
 )
  Write-Output "Downloading $url to $file"
  $downloader = new-object System.Net.WebClient

  $defaultCreds = [System.Net.CredentialCache]::DefaultCredentials
  if ($defaultCreds -ne $null) {
    $downloader.Credentials = $defaultCreds
  }

  # check if a proxy is required
  $explicitProxy = $env:chocolateyProxyLocation
  $explicitProxyUser = $env:chocolateyProxyUser
  $explicitProxyPassword = $env:chocolateyProxyPassword
  if ($explicitProxy -ne $null) {
    # explicit proxy
  $proxy = New-Object System.Net.WebProxy($explicitProxy, $true)
  if ($explicitProxyPassword -ne $null) {
    $passwd = ConvertTo-SecureString $explicitProxyPassword -AsPlainText -Force
    $proxy.Credentials = New-Object System.Management.Automation.PSCredential ($explicitProxyUser, $passwd)
  }

  Write-Output "Using explicit proxy server '$explicitProxy'."
    $downloader.Proxy = $proxy

  } elseif (!$downloader.Proxy.IsBypassed($url))
  {
  # system proxy (pass through)
    $creds = $defaultCreds
    if ($creds -eq $null) {
      Write-Debug "Default credentials were null. Attempting backup method"
      $cred = get-credential
      $creds = $cred.GetNetworkCredential();
    }
    $proxyaddress = $downloader.Proxy.GetProxy($url).Authority
    Write-Output "Using system proxy server '$proxyaddress'."
    $proxy = New-Object System.Net.WebProxy($proxyaddress)
    $proxy.Credentials = $creds
    $downloader.Proxy = $proxy
  }

  $downloader.DownloadFile($url, $file)
}
Download-File -url $url -file master.zip
Download-File -url $node -file node.exe
Download-File -url $npm -file npm.zip
$7zaExe="7zip.exe"
Download-File 'https://chocolatey.org/7za.exe' "$7zaExe"
# that's presumably done... Next
Start-Process "$7zaExe" -ArgumentList "x -o`".\`" -y `"master.zip`"" -Wait -NoNewWindow
Start-Process "$7zaExe" -ArgumentList "x -o`".\`" -y `"npm.zip`"" -Wait -NoNewWindow
move "electron-browser-master\*" ".\"-Force
Start-Process "node.exe" -ArgumentList "node_modules\npm\bin\npm-cli.js install -d" -Wait -NoNewWindow
Start-Process "node.exe" -ArgumentList "node_modules\npm\bin\npm-cli.js start" -UseNewEnvironment

}
catch [System.Exception] {
    Write-Host -Object [System.Exception]
}
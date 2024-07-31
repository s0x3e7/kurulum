# 1. URL'den ZIP dosyasını indirmek
$zipUrl = "https://github.com/Yamato-Security/hayabusa/releases/download/v2.16.0/hayabusa-2.16.0-win-x64.zip"
$zipPath = "C:\pure7soc.zip"
$extractPath = "C:\pure7soc"
$exeName = "hayabusa-2.16.0-win-x64.exe"
$exePath = "$extractPath\$exeName"

# ZIP dosyasını indirmek
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath

# 2. 7-Zip kontrolü ve gerekirse indirilmesi ve kurulması
$sevenZipPath = "C:\Program Files\7-Zip\7z.exe"
if (-Not (Test-Path $sevenZipPath)) {
    $sevenZipInstallerUrl = "https://www.7-zip.org/a/7z1900-x64.exe"
    $sevenZipInstallerPath = "$env:TEMP\7z1900-x64.exe"
    # 7-Zip indirilmesi
    Invoke-WebRequest -Uri $sevenZipInstallerUrl -OutFile $sevenZipInstallerPath
    # 7-Zip kurulması
    Start-Process -FilePath $sevenZipInstallerPath -ArgumentList "/S" -Wait
}

# 3. ZIP dosyasının çıkarılması
if (-Not (Test-Path $extractPath)) {
    New-Item -Path $extractPath -ItemType Directory
}

Start-Process -FilePath $sevenZipPath -ArgumentList "x `"$zipPath`" -o`"$extractPath`" -y" -Wait

# 4. hayabusa.exe'yi çalıştırma
Start-Process -FilePath $exePath -ArgumentList "csv-timeline -d C:\Windows\System32\winevt\Logs\ -r .\rules\ -o pure7soc.csv -w" -NoNewWindow -Wait

# 5. Oluşan CSV dosyasını zipleme
$csvFilePath = "$extractPath\pure7soc.csv"
$computerName = $env:COMPUTERNAME
$zipOutputPath = "$extractPath\pure7soc_$computerName.zip"

if (Test-Path $csvFilePath) {
    Compress-Archive -Path $csvFilePath -DestinationPath $zipOutputPath
    Write-Host "CSV dosyası başarıyla ziplendi: $zipOutputPath"
} else {
    Write-Host "CSV dosyası bulunamadı: $csvFilePath"
}

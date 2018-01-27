Add-Type -AssemblyName System.IO.Compression.FileSystem

$build_dir = $env:temp + "\mimikatz-master"
$zip_path  = $env:temp + "\mimikatz-master.zip"
$out_dir   = [Environment]::GetFolderPath("Desktop")

Write-Host "[-] Downloading from github"
$web = New-Object Net.Webclient;
$web.DownloadFile("https://github.com/gentilkiwi/mimikatz/archive/master.zip", $zip_path);

# 解压缩
Write-Host "[-] Expanding zip"
if (Test-Path -Path $build_dir)
{
    cmd /c del /Q /F /S "$build_dir" 
    cmd /c rmdir "$build_dir" /q /s
}
# Remove-Item –Path "$build_dir" -Recurse -Force 
[System.IO.Compression.ZipFile]::ExtractToDirectory($zip_path, "$build_dir\..")

# 修正编译脚本
Write-Host "[-] Correcting vcxproj files"
Get-ChildItem "$build_dir\*\*.vcxproj" | ForEach-Object -Process {
    Write-Host " - " $_
    (Get-Content $_) -Replace '<PreprocessorDefinitions>', '<PreprocessorDefinitions>UNICODE;' -Replace '<TreatWarningAsError>true</TreatWarningAsError>', '<TreatWarningAsError>false</TreatWarningAsError>' | Set-Content $_
}

# 开始编译
Write-Host "[-] Start compilation"
cd $build_dir
cmd /c 'call "C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\vcvarsall.bat" && msbuild /p:PlatformToolset=v110 /p:Platform=x64'
cmd /c 'call "C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\vcvarsall.bat" && msbuild /p:PlatformToolset=v110'

Write-Host "[-] Copying files to $out_dir"
Copy-Item "$build_dir\Win32\mimikatz.exe" -Destination "$out_dir\mimikatz32.exe"
Copy-Item "$build_dir\x64\mimikatz.exe" -Destination "$out_dir\mimikatz64.exe"


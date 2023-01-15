function Get-vcpkgDirPath {
    $path = Get-Content $PSScriptRoot/vcpkgConfig
    return $path
}

function Set-vcpkgDirPath {
    param (
        [string] $path
    )
    $path = $path.Trim('\')
    $path > "$PSScriptRoot\vcpkgConfig"
}

function Invoke-vcpkg {
    param (
        [string[]] $commandArgs 
    )
    $vcpkg = "$(get-vcpkgDirPath)/vcpkg.exe"
    &$vcpkg $commandArgs
}

function parserLines {
    param (
        [string[]] $lines,
        [Int16] $skiplines = 0
    )
    $lines | Select-Object -SkipLast $skiplines | ForEach-Object {
        $columns = $_ -split "\s{2,}|(?<!(version|ES))\s(?=\d)" | Where-Object { $_ }
        [PSCustomObject]@{
            PakageName    = $columns[0]
            Version       = if ($columns.count -eq 2) { "" } else { $columns[1] }
            Descriptsions = if ($columns.count -ge 3) { $columns[2] } else { $columns[1] }
        } 
    }
}
function Find-vcpkg {
    param (
        [string] $pkgName,
        [string] $commandArgs = ''
    )
    $lines = Invoke-vcpkg "search", $commandArgs, $pkgName
    parserLines $lines -skiplines 2
}

function Get-vcpkgInstallList {
    param (
        [string] $commandArgs = ''
    )
    $lines = Invoke-vcpkg "list", $commandArgs
    parserLines $lines
}

function Install-vcpkgPackage {
    param (
        [string] $pakName,
        [string] $plantform = "x64-windows",
        [string] $commandArgs = ''
    )
    $pakName = "$($pakName):$plantform"
    Invoke-vcpkg "install", $commandArgs, $pakName
}

function Remove-vcpkgPackage {
    param (
        [string] $pakName,
        [string] $commandArgs = ''
    )
    Invoke-vcpkg "remove", $commandArgs, $pakName
}

Export-ModuleMember -Function Get-vcpkgDirPath
Export-ModuleMember -Function Set-vcpkgDirPath
Export-ModuleMember -Function Invoke-vcpkg
Export-ModuleMember -Function Find-vcpkg
Export-ModuleMember -Function Get-vcpkgInstallList
Export-ModuleMember -Function Install-vcpkgPackage
Export-ModuleMember -Function Remove-vcpkgPackage
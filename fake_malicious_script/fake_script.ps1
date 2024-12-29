function Print-AsciiArt {
    Write-Host "  _____   ____  __  __ ______    _____  _    _  _______  _    _ _____   _______ "
    Write-Host " / ____| / __ \|  \/  |  ____|  |  __ || |  | ||__   __|| |  | |  __ \ |   ____|"
    Write-Host "| (___  | |  | | \  / | |__     | |__  | |  | |   | |   | |  | | |__) ||  |__   "
    Write-Host " \___ \ | |  | | |\/| |  __|    |  __| | |  | |   | |   | |  | |  _  / |   __|  "
    Write-Host " ____) || |__| | |  | | |____   | |    | |__| |   | |   | |__| | | \ \ |  |____ "
    Write-Host "|_____/  \____/|_|  |_|______|  |_|    |______|   |_|   |______|_|  \_\|_______|"

    Write-Host "                          Created by S.F."
}

Print-AsciiArt

$text = "Hi! We're Some Future. If you have this file in your machine that means you're not being careful enough with what you open from the internet. We advise you to learn more about how to protect yourself before downloading anything from the internet."
$infoFilePath = "stolen_info.txt"

del $infoFilePath

function Create-File {
    Add-Content -Path $infoFilePath -Value "$text"
    Start $infoFilePath
}

Create-File


<#
    To use it, just change the $uriList variable to the desired album links from khinsider.com and run the script. 
    You can also change the $fileFormat variable to the desired file format to download (mp3, flac, etc). 
    The script will create a folder for each album and download all the files to it. It will use $outFolderRoot as the root folder for all the albums.
    The script will wait 3 seconds between each download to avoid being blocked by the server.

    Example:
        $uriList = @("https://downloads.khinsider.com/game-soundtracks/album/descent-2")
        $fileFormat = "mp3"
        $outFolderRoot = "S:\Mp3\Games\" # must exists    

#>

$uriList = @("https://downloads.khinsider.com/game-soundtracks/album/descent-2")
$fileFormat = "mp3"

$outFolderRoot = "S:\Mp3\Games\" # must exists for now

foreach($uri in $uriList){    
    $source = Invoke-WebRequest -UseBasicParsing -Uri $uri
    $outFolder = $outFolderRoot + ($uri -split "/")[-1]

    if( -not (Test-Path $outFolder) ) {
        New-Item -Path $outFolder -ItemType Directory
    }

    $uniquelinks = @()
    foreach($l in $source.Links){    
        if($l.href -like "*.mp3" -and $l.href -notin $uniquelinks){ 
            $uniquelinks += $l.href                
            $intermediateLink = "https://downloads.khinsider.com" + $l.href        
            $intermediatePage = Invoke-WebRequest -UseBasicParsing -Uri $intermediateLink                    
            $dlLink = ($intermediatePage.Links | Where-Object { $_.outerHTML -like "*.$fileFormat*"}).href
            write-host "Processing:$dlLink"
            $fileName = ($dlLink -split "/")[-1] -replace "%20"," " -replace "%28","(" -replace "%29",")" -replace "%27","'" 
            $outputPath = $outFolder + "\" + $fileName
            Invoke-WebRequest -ContentType 'audio/mpeg' -Uri $dlLink -OutFile $outputPath
            Start-Sleep -Seconds 3                            
        }
    }
}

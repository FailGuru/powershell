Set-StrictMode -Version Latest


function Get-Line {
    param(
        [int]
        $Width,
        [char]
        $Pad,
        [char]
        $Border,
        [string]
        $Text = ""
    )
    $l = ($Width - $Text.Length - 2) / 2
    "$((Get-Fill -Length ([Math]::Floor($l)) -Pad $Pad -Border $Border -Start)+$Text+(Get-Fill -Length ([Math]::Ceiling($l)) -Pad $Pad -Border $Border))"
}

function Get-Fill {
    param(
        [int]
        $Length,
        [char]
        $Pad,
        [char]
        $Border,
        [switch]
        $Start
    )
    $c = [char[]]::new($Length)
    for ($i = 0; $i -lt $c.Count; $i++) {
        $c[$i] = $Pad 
    }
    if ($Start.IsPresent) {
        $c[0] = $Border
    }
    else {
        $c[$Length - 1] = $Border
    }
    [String]::new($c)
}

function Get-Rectangle {
    param(
        [string]
        $Message,
        [string]
        $GuruAlert,
        [int]
        $Width = 89,
        [char]
        $Border
    )
    $m = ""
    if ($Message.Length -gt 0) {
        $m += "`n$(Get-Line -Pad ' ' -Border $Border -Text $Message -Width $Width)"
    }
    @"
$(Get-Line -Pad $Border -Border $Border -Width $Width)
$(Get-Line -Pad ' ' -Border $Border -Text "Software Failure. Press any key to continue." -Width $Width)$m
$(Get-Line -Pad ' ' -Border $Border -Text "Guru Meditation #$($GuruAlert)" -Width $Width)
$(Get-Line -Pad $Border -Border $Border -Width $Width)
"@
}

function Format-GuruAlert {
    param(
        [uint32]
        $GuruCode
    )
    if ($GuruCode -eq 0 -or $GuruCode -gt ([uint32]"0xFFFFFFFF")) {
        return "00000011.48454C50"
    }
    $hexGuru = $GuruCode.ToString("X")
    while ($hexGuru.Length -lt 8) { $hexGuru = "0$($hexGuru)"}
    return "00000011.$($hexGuru)"
}

function Invoke-GuruMeditation {
    param(
        [string]
        $Message,
        [uint32]
        $GuruCode = 0,
        [int]
        $Width = 89,
        [switch]
        $CoverTerminal,
        [switch]
        $FullWidth
    )

    $MinBlinks = $Env:MIN_GURU_BLINKS -as [int]
    if ($MinBlinks -le 0) {
        $MinBlinks = 6
    } 

    $MaxBlinks = $Env:MAX_GURU_BLINKS -as [int]
    if ($MaxBlinks -le 0) {
        $MaxBlinks = [int]::MaxValue
    } 

    if ($MaxBlinks -lt $MinBlinks) {
        $MaxBlinks = $MinBlinks
    }
    
    $esc = [char]27
    $obg = $Host.UI.RawUI.BackgroundColor
    $ocs = $Host.UI.RawUI.cursorsize
    $y = $Host.UI.RawUI.CursorPosition.Y


    if ($FullWidth.IsPresent -or $CoverTerminal.IsPresent) {
        $Width = $Host.UI.RawUI.WindowSize.Width
    }

    if ($CoverTerminal.IsPresent) {
        $cover = ""
        for ($i = 0; $i -lt $Host.UI.RawUI.WindowSize.Height; $i++) {
            for ($j = 0; $j -lt $Host.UI.RawUI.WindowSize.Width; $j++) {
                $cover += "$esc[40m "
            }
            $cover += "`n"
        }
        $Host.UI.RawUI.BackgroundColor = "black"
        Write-Host $cover -NoNewline
        $y = 0
    }


    if ($Width -lt 30) {
        $Width = $Host.UI.RawUI.WindowSize.Width
        $Message = "requested width too short for guru."
        $GuruCode = 0
    }
    if ($Message.Length -gt $Width - 8) {
        $Message = $Message.Substring(0, $Width - 16) + "..."
        $GuruCode = 0
    }
    $guruAlert = Format-GuruAlert $GuruCode
    $Host.UI.RawUI.cursorsize = 0
    $s = @( (Get-Rectangle -Message $Message -GuruAlert $guruAlert -Width $Width -Border '#'), (Get-Rectangle -Message $Message -GuruAlert $guruAlert -Width $Width -Border ' '))
    $i = 0

    if ($y -ge $Host.UI.RawUI.WindowSize.Height - 6) {
        Write-Host "`n`n`n`n`n`n" -NoNewline
        $y = $y-6
    }

    $start = "$esc[$($y);0H"
    do {
        Write-Host "$start`n$($s[$i%2])`n" -ForegroundColor Red -NoNewline
        $i++
        Start-Sleep -Seconds 1
        if ($i -eq $MaxBlinks - 1) {
            break
        }
    } while ($i -lt $MinBlinks -or !([Console]::KeyAvailable))
    $Host.UI.RawUI.cursorsize = $ocs
    if ($CoverTerminal.IsPresent) {
        $Host.UI.RawUI.BackgroundColor = $obg
    }
}

New-Alias -Name callguru -Value Invoke-GuruMeditation

Export-ModuleMember -Function "Invoke-GuruMeditation" -Alias "callguru"
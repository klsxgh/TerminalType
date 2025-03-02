param (
    [int]$Duration = 0,
    [switch]$Help
)

if ($Help) {
    Write-Host "TerminalType - Typing test with random words from words.txt" -ForegroundColor Cyan
    Write-Host "Usage: .\TerminalType.ps1 [-Duration <seconds>] [-Help]" -ForegroundColor Yellow
    exit
}

function Show-Banner {
    Clear-Host
    Write-Host "`n  ===============================  " -ForegroundColor Cyan
    Write-Host "      Terminal Typing Test       " -ForegroundColor Cyan
    Write-Host "  ===============================  `n" -ForegroundColor Cyan
}

function Get-TestText {
    param (
        [switch]$RandomWords
    )
    
    if ($RandomWords) {
        $wordFile = Join-Path -Path $PSScriptRoot -ChildPath "words.txt"
        if (-not (Test-Path $wordFile)) {
            Write-Host "Error: words.txt not found in script directory!" -ForegroundColor Red
            return "Error - no words file"
        }
        $wordList = Get-Content -Path $wordFile
        $sentenceLength = Get-Random -Minimum 5 -Maximum 11
        $words = for ($i = 0; $i -lt $sentenceLength; $i++) {
            $wordList | Get-Random
        }
        return ($words -join " ") + "."
    } else {
        $sentences = @(
            "The quick brown fox jumps over the lazy dog.",
            "She sells seashells by the seashore.",
            "Peter Piper picked a peck of pickled peppers."
        )
        return $sentences | Get-Random
    }
}

function Start-TypingTest {
    param (
        [int]$TestDuration,
        [switch]$RandomWords
    )
    
    Show-Banner
    Write-Host "Duration: $TestDuration seconds" -ForegroundColor Yellow
    Write-Host "Mode: $(if ($RandomWords) { 'Random Words' } else { 'Predefined Sentence' })" -ForegroundColor Yellow
    Write-Host "Type the following text:" -ForegroundColor Yellow
    
    $targetText = Get-TestText -RandomWords:$RandomWords
    Write-Host "`n$targetText`n" -ForegroundColor Green
    
    Write-Host "Press Enter when ready..." -ForegroundColor Yellow
    $null = Read-Host
    
    Write-Host "`nGO! Type the text and press Enter within $TestDuration seconds:" -ForegroundColor Red
    $startTime = Get-Date
    $userInput = ""
    $inputComplete = $false
    
    while ([Console]::KeyAvailable) { $null = [Console]::ReadKey($true) }
    
    $elapsedTime = 0
    while ($elapsedTime -lt $TestDuration -and -not $inputComplete) {
        $elapsedTime = ((Get-Date) - $startTime).TotalSeconds
        $timeLeft = $TestDuration - [math]::Floor($elapsedTime)
        
        Write-Host "`rTime left: $timeLeft seconds    $userInput$(" " * 20)" -ForegroundColor Yellow -NoNewline
        
        if ([Console]::KeyAvailable) {
            $key = [Console]::ReadKey($true)
            if ($key.Key -eq "Enter") {
                $inputComplete = $true
            } elseif ($key.Key -eq "Backspace" -and $userInput.Length -gt 0) {
                $userInput = $userInput.Substring(0, $userInput.Length - 1)
            } elseif ($key.KeyChar -match '[ -~]') {
                $userInput += $key.KeyChar
            }
        }
        
        Start-Sleep -Milliseconds 100
    }
    
    if (-not $inputComplete) {
        Write-Host "`rTime's up!                      " -ForegroundColor Red
        $elapsedTime = $TestDuration
    } else {
        $elapsedTime = ((Get-Date) - $startTime).TotalSeconds
    }
    
    if ($userInput -eq "") { $userInput = $null }
    
    $typedChars = if ($null -eq $userInput) { 0 } else { $userInput.Length }
    $targetChars = $targetText.Length
    
    $wpm = if ($elapsedTime -gt 0) { 
        [math]::Round(($typedChars / 5) * (60 / $elapsedTime)) 
    } else { 0 }
    
    $correctChars = 0
    if ($userInput) {
        for ($i = 0; $i -lt [math]::Min($typedChars, $targetChars); $i++) {
            if ($userInput[$i] -eq $targetText[$i]) {
                $correctChars++
            }
        }
    }
    
    $accuracy = if ($typedChars -gt 0) {
        [math]::Round(($correctChars / $typedChars) * 100)
    } else { 0 }
    
    Show-Banner
    Write-Host "================ RESULTS ================" -ForegroundColor Cyan
    Write-Host "WPM: $wpm" -ForegroundColor Green
    Write-Host "Accuracy: $accuracy%" -ForegroundColor Green
    Write-Host "Characters: $typedChars / $targetChars" -ForegroundColor Yellow
    Write-Host "Time: $([math]::Round($elapsedTime, 1)) seconds" -ForegroundColor Yellow
    Write-Host "Mode: $(if ($RandomWords) { 'Random Words' } else { 'Predefined Sentence' })" -ForegroundColor Yellow
    
    Write-Host "`nTarget:" -ForegroundColor Magenta
    Write-Host $targetText -ForegroundColor Gray
    Write-Host "`nYour input:" -ForegroundColor Magenta
    if ($null -eq $userInput) {
        Write-Host "(No input provided)" -ForegroundColor Gray
    } else {
        Write-Host $userInput -ForegroundColor Gray
    }
    
    return $wpm, $accuracy
}

function Show-Menu {
    Show-Banner
    Write-Host "Menu loaded successfully" -ForegroundColor Green
    Write-Host "Select mode:" -ForegroundColor Yellow
    Write-Host "1. Random Words (from words.txt)" -ForegroundColor Cyan
    Write-Host "2. Predefined Sentences" -ForegroundColor Cyan
    Write-Host "Q. Quit" -ForegroundColor Red
    Write-Host "Enter your choice (1, 2, or Q):" -ForegroundColor Yellow
    
    $modeChoice = Read-Host "Choice"
    
    if ($modeChoice -eq 'q' -or $modeChoice -eq 'Q') {
        return $false, $null, $null
    }
    
    $randomWords = $modeChoice -eq '1'
    
    Show-Banner
    Write-Host "Select duration:" -ForegroundColor Yellow
    Write-Host "1. 15 seconds" -ForegroundColor Cyan
    Write-Host "2. 30 seconds" -ForegroundColor Cyan
    Write-Host "3. 60 seconds" -ForegroundColor Cyan
    Write-Host "4. Custom (enter seconds)" -ForegroundColor Cyan
    Write-Host "Enter your choice (1-4):" -ForegroundColor Yellow
    
    $durationChoice = Read-Host "Choice"
    $duration = switch ($durationChoice) {
        '1' { 15 }
        '2' { 30 }
        '3' { 60 }
        '4' { 
            $custom = Read-Host "Enter duration in seconds (10-300)"
            [int]$customDuration = [math]::Max(10, [math]::Min(300, $custom))
            $customDuration
        }
        default { 30 }
    }
    
    $wpm, $accuracy = Start-TypingTest -TestDuration $duration -RandomWords:$randomWords
    
    Write-Host "`nTry again? (Y/N)" -ForegroundColor Yellow
    $retry = Read-Host
    return ($retry -eq 'Y' -or $retry -eq 'y'), $wpm, $accuracy
}

if ($Duration -ge 10 -and $Duration -le 300) {
    Write-Host "Running test directly with duration $Duration seconds" -ForegroundColor Green
    Start-TypingTest -TestDuration $Duration -RandomWords
} else {
    Write-Host "Entering menu mode" -ForegroundColor Green
    $continue = $true
    $bestWpm = 0
    while ($continue) {
        $continue, $wpm, $accuracy = Show-Menu
        if ($wpm -gt $bestWpm) { $bestWpm = $wpm }
        if (-not $continue) {
            Show-Banner
            Write-Host "Thanks for playing!" -ForegroundColor Cyan
            Write-Host "Your best WPM: $bestWpm" -ForegroundColor Green
        }
    }
}
#Requires -Version 5.1
<#
.SYNOPSIS
    Ralph - Iterative PRD implementation with GitHub Copilot CLI

.DESCRIPTION
    Runs GitHub Copilot CLI in iterations to implement a PRD (Product Requirements Document)
    with context from skills, PRD file, and progress tracking.

.PARAMETER Prompt
    Path to the prompt text file (required)

.PARAMETER Prd
    Path to optional PRD JSON file

.PARAMETER Progress
    Path to optional progress.txt file (defaults to progress.txt in script directory)

.PARAMETER Skill
    Comma-separated list of skills to include from skills/<name>/SKILL.md

.PARAMETER AllowProfile
    Tool permission profile: safe, dev, or locked

.PARAMETER AllowTools
    Array of tool specs to allow (can be specified multiple times)

.PARAMETER DenyTools
    Array of tool specs to deny (can be specified multiple times)

.PARAMETER Iterations
    Number of iterations to run (required)

.EXAMPLE
    .\ralph.ps1 -Prompt .\prompts\default.txt -AllowProfile dev -Iterations 5

.EXAMPLE
    .\ralph.ps1 -Prompt .\prompts\default.txt -Progress .\plans\ui-redesign\progress.txt -AllowProfile dev -Iterations 5

.EXAMPLE
    .\ralph.ps1 -Prompt .\prompts\default.txt -Prd .\prd.json -Skill "typescript,react" -AllowProfile safe -Iterations 3
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Prompt,
    
    [Parameter(Mandatory=$false)]
    [string]$Prd,
    
    [Parameter(Mandatory=$false)]
    [string]$Progress,
    
    [Parameter(Mandatory=$false)]
    [string]$Skill,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('safe', 'dev', 'locked')]
    [string]$AllowProfile,
    
    [Parameter(Mandatory=$false)]
    [string[]]$AllowTools = @(),
    
    [Parameter(Mandatory=$false)]
    [string[]]$DenyTools = @(),
    
    [Parameter(Mandatory=$true)]
    [ValidateScript({$_ -gt 0})]
    [int]$Iterations
)

# Set strict mode for better error handling
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$RALPH_VERSION = "1.1.0"

# Get script directory
$SCRIPT_DIR = $PSScriptRoot

# Helper function to trim whitespace
function Trim-String {
    param([string]$Text)
    return $Text.Trim()
}

# Default model if not provided via environment variable
$MODEL = if ($env:MODEL) { $env:MODEL } else { "claude-sonnet-4.5" }

# Validate prompt file
if (-not (Test-Path $Prompt -PathType Leaf)) {
    Write-Error "Error: prompt file not readable: $Prompt"
    exit 1
}

# Validate PRD file if provided
if ($Prd -and -not (Test-Path $Prd -PathType Leaf)) {
    Write-Error "Error: PRD file not readable: $Prd"
    exit 1
}

# Validate progress file
$progressFile = if ($Progress) { $Progress } else { Join-Path $SCRIPT_DIR "progress.txt" }
if (-not (Test-Path $progressFile -PathType Leaf)) {
    Write-Error "Error: progress file not readable: $progressFile"
    exit 1
}

# Parse skills from comma-separated string
$skills = @()
if ($Skill) {
    $skills = $Skill -split ',' | ForEach-Object { Trim-String $_ } | Where-Object { $_ }
}

# Validate that either AllowProfile or AllowTools is specified
if (-not $AllowProfile -and $AllowTools.Count -eq 0) {
    Write-Error "Error: you must specify -AllowProfile or at least one -AllowTools"
    exit 1
}

# Build copilot tool arguments
$copilotToolArgs = @()

# Always deny dangerous commands
$copilotToolArgs += "--deny-tool"
$copilotToolArgs += "shell(rm)"
$copilotToolArgs += "--deny-tool"

# Add profile-based tool permissions
if ($AllowTools.Count -eq 0 -and $AllowProfile) {
    switch ($AllowProfile) {
        'dev' {
            $copilotToolArgs += "--allow-all-tools"
            $copilotToolArgs += "--allow-tool"
            $copilotToolArgs += "write"
            $copilotToolArgs += "--allow-tool"
            $copilotToolArgs += "shell(pnpm:*)"
            $copilotToolArgs += "--allow-tool"
            $copilotToolArgs += "shell(git:*)"
        }
        'safe' {
            $copilotToolArgs += "--allow-tool"
            $copilotToolArgs += "write"
            $copilotToolArgs += "--allow-tool"
            $copilotToolArgs += "shell(pnpm:*)"
            $copilotToolArgs += "--allow-tool"
            $copilotToolArgs += "shell(git:*)"
        }
        'locked' {
            $copilotToolArgs += "--allow-tool"
            $copilotToolArgs += "write"
        }
    }
}

# Add custom allowed tools
foreach ($tool in $AllowTools) {
    $copilotToolArgs += "--allow-tool"
    $copilotToolArgs += $tool
}

# Add custom denied tools
foreach ($tool in $DenyTools) {
    $copilotToolArgs += "--deny-tool"
    $copilotToolArgs += $tool
}

# Main iteration loop
for ($i = 1; $i -le $Iterations; $i++) {
    Write-Host "`nIteration $i"
    Write-Host "------------------------------------"

    # Create context file combining skills, PRD, and progress
    $contextFile = [System.IO.Path]::GetTempFileName()
    
    $contextContent = @()
    $contextContent += "# Context"
    $contextContent += ""
    
    # Add skills if specified
    if ($skills.Count -gt 0) {
        $contextContent += "## Skills"
        foreach ($skillName in $skills) {
            $skillFile = Join-Path $SCRIPT_DIR "skills\$skillName\SKILL.md"
            if (-not (Test-Path $skillFile -PathType Leaf)) {
                Write-Error "Error: skill not found/readable: $skillFile"
                exit 1
            }
            $contextContent += ""
            $contextContent += "### $skillName"
            $contextContent += ""
            $contextContent += Get-Content $skillFile -Raw
        }
        $contextContent += ""
    }
    
    # Add PRD if specified
    if ($Prd) {
        $contextContent += "## PRD ($Prd)"
        $contextContent += Get-Content $Prd -Raw
        $contextContent += ""
    }
    
    # Add progress
    $contextContent += "## progress.txt"
    $contextContent += Get-Content $progressFile -Raw
    $contextContent += ""
    
    # Write context to temp file
    $contextContent -join "`n" | Out-File -FilePath $contextFile -Encoding utf8 -NoNewline
    
    # Create combined prompt file
    $combinedPromptFile = [System.IO.Path]::GetTempFileName()
    
    $promptContent = @()
    $promptContent += Get-Content $contextFile -Raw
    $promptContent += ""
    $promptContent += "# Prompt"
    $promptContent += ""
    $promptContent += Get-Content $Prompt -Raw
    $promptContent += ""
    
    # Write combined prompt to temp file
    $promptContent -join "`n" | Out-File -FilePath $combinedPromptFile -Encoding utf8 -NoNewline
    
    # Execute Copilot CLI with output capture
    $transcriptFile = [System.IO.Path]::GetTempFileName()
    
    # Get repository root (parent of ralph directory)
    $repoRoot = Split-Path $SCRIPT_DIR -Parent
    
    # Build copilot command
    $copilotArgs = @(
        "--add-dir", $repoRoot,
        "--model", $MODEL,
        "--stream", "off",
        "-p", "@$combinedPromptFile Follow the attached prompt."
    )
    $copilotArgs += $copilotToolArgs
    
    # Execute copilot and capture output
    try {
        # Use Tee-Object to show output in real-time AND save to file
        & copilot @copilotArgs 2>&1 | Tee-Object -FilePath $transcriptFile
        $status = $LASTEXITCODE
    } catch {
        Write-Host "Error executing Copilot: $_"
        $status = 1
    }
    
    # Read transcript file for completion check
    if (Test-Path $transcriptFile) {
        $result = Get-Content $transcriptFile -Raw -ErrorAction SilentlyContinue
    }
    
    # Clean up temporary files
    Remove-Item $contextFile -Force -ErrorAction SilentlyContinue
    Remove-Item $combinedPromptFile -Force -ErrorAction SilentlyContinue
    Remove-Item $transcriptFile -Force -ErrorAction SilentlyContinue
    
    # Check exit status
    if ($status -ne 0) {
        Write-Host "Copilot exited with status $status; continuing to next iteration."
        continue
    }
    
    # Check for completion signal
    if ($result -and $result -match '<promise>COMPLETE</promise>') {
        Write-Host "PRD complete, exiting."
        
        # Optional desktop notification (if tt command exists)
        if (Get-Command tt -ErrorAction SilentlyContinue) {
            & tt notify "PRD complete after $i iterations"
        }
        
        exit 0
    }
}

Write-Host "Finished $Iterations iterations without receiving the completion signal."

Param(
    [Parameter(HelpMessage = "GitHub token for API authentication", Mandatory = $false)]
    [string] $token,
    [Parameter(HelpMessage = "Repository in the format 'owner/repo' (default is current repository)", Mandatory = $false)]
    [string] $repository,
    [Parameter(HelpMessage = "Output format - 'table', 'json', or 'list' (default is table)", Mandatory = $false)]
    [string] $outputFormat = "table"
)

. (Join-Path -Path $PSScriptRoot -ChildPath "..\AL-Go-Helper.ps1" -Resolve)
Import-Module (Join-Path -Path $PSScriptRoot -ChildPath '..\TelemetryHelper.psm1' -Resolve)

function GetOpenPullRequests {
    Param(
        [string] $repository,
        [hashtable] $headers
    )
    
    try {
        $url = "https://api.github.com/repos/$repository/pulls?state=open&per_page=100"
        Write-Host "Fetching open pull requests from: $url"
        
        $response = Invoke-WebRequest -UseBasicParsing -Headers $headers -Uri $url
        $pullRequests = $response.Content | ConvertFrom-Json
        
        return $pullRequests
    }
    catch {
        $statusCode = $null
        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode
        }
        
        if ($statusCode -eq 403) {
            Write-Host -ForegroundColor Yellow "Warning: Access forbidden. This may be due to:"
            Write-Host -ForegroundColor Yellow "  - API rate limiting (without authentication)"
            Write-Host -ForegroundColor Yellow "  - Repository is private and requires authentication"
            Write-Host -ForegroundColor Yellow "  - Token lacks necessary permissions"
            Write-Host -ForegroundColor Yellow "Try providing a valid GitHub token with appropriate permissions."
        } elseif ($statusCode -eq 404) {
            Write-Host -ForegroundColor Red "Repository '$repository' not found or not accessible."
        } else {
            Write-Host -ForegroundColor Red "Error fetching pull requests: $($_.Exception.Message)"
        }
        throw
    }
}

function FormatPullRequestsTable {
    Param(
        [array] $pullRequests
    )
    
    if ($pullRequests.Count -eq 0) {
        Write-Host "No open pull requests found."
        return
    }
    
    Write-Host ""
    Write-Host "Open Pull Requests:" -ForegroundColor Green
    Write-Host "===================" -ForegroundColor Green
    Write-Host ""
    
    $pullRequests | Format-Table @{
        Label = "PR #"; Expression = { $_.number }; Width = 6
    }, @{
        Label = "Title"; Expression = { 
            if ($_.title.Length -gt 60) { 
                $_.title.Substring(0, 57) + "..." 
            } else { 
                $_.title 
            }
        }; Width = 60
    }, @{
        Label = "Author"; Expression = { $_.user.login }; Width = 15
    }, @{
        Label = "Created"; Expression = { 
            [DateTime]::Parse($_.created_at).ToString("yyyy-MM-dd") 
        }; Width = 12
    }, @{
        Label = "Draft"; Expression = { 
            if ($_.draft) { "Yes" } else { "No" }
        }; Width = 5
    } -AutoSize
}

function FormatPullRequestsList {
    Param(
        [array] $pullRequests
    )
    
    if ($pullRequests.Count -eq 0) {
        Write-Host "No open pull requests found."
        return
    }
    
    Write-Host ""
    Write-Host "Open Pull Requests:" -ForegroundColor Green
    Write-Host "===================" -ForegroundColor Green
    
    foreach ($pr in $pullRequests) {
        Write-Host ""
        Write-Host "PR #$($pr.number): $($pr.title)" -ForegroundColor Cyan
        Write-Host "  Author: $($pr.user.login)"
        Write-Host "  Created: $([DateTime]::Parse($pr.created_at).ToString('yyyy-MM-dd HH:mm:ss'))"
        Write-Host "  URL: $($pr.html_url)"
        if ($pr.draft) {
            Write-Host "  Status: Draft" -ForegroundColor Yellow
        }
        if ($pr.body -and $pr.body.Length -gt 0) {
            $body = $pr.body
            if ($body.Length -gt 100) {
                $body = $body.Substring(0, 97) + "..."
            }
            Write-Host "  Description: $body"
        }
    }
    Write-Host ""
}

function FormatPullRequestsJson {
    Param(
        [array] $pullRequests
    )
    
    $output = @()
    foreach ($pr in $pullRequests) {
        $output += @{
            number = $pr.number
            title = $pr.title
            author = $pr.user.login
            created_at = $pr.created_at
            html_url = $pr.html_url
            draft = $pr.draft
            body = $pr.body
        }
    }
    
    $output | ConvertTo-Json -Depth 3
}

# Main execution
try {
    # Determine repository
    if (-not $repository) {
        if ($env:GITHUB_REPOSITORY) {
            $repository = $env:GITHUB_REPOSITORY
        } else {
            throw "Repository parameter is required when not running in GitHub Actions environment"
        }
    }
    
    # Setup headers for GitHub API
    $headers = @{
        'Accept' = 'application/vnd.github+json'
        'X-GitHub-Api-Version' = '2022-11-28'
        'User-Agent' = 'AL-Go-ListOpenPullRequests'
    }
    
    # Add authorization if token is provided
    if ($token) {
        $headers['Authorization'] = "Bearer $token"
    }
    
    # Get open pull requests
    $pullRequests = GetOpenPullRequests -repository $repository -headers $headers
    
    # Output results based on format
    switch ($outputFormat.ToLower()) {
        "json" {
            FormatPullRequestsJson -pullRequests $pullRequests
        }
        "list" {
            FormatPullRequestsList -pullRequests $pullRequests
        }
        default {
            FormatPullRequestsTable -pullRequests $pullRequests
        }
    }
    
    # Set output for GitHub Actions
    if ($env:GITHUB_OUTPUT) {
        $count = $pullRequests.Count
        "pr-count=$count" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
        
        # Also output as JSON for potential consumption by other actions
        $jsonOutput = FormatPullRequestsJson -pullRequests $pullRequests
        "pr-list<<EOF" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
        $jsonOutput | Out-File -FilePath $env:GITHUB_OUTPUT -Append
        "EOF" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
    }
    
    Write-Host ""
    Write-Host "Found $($pullRequests.Count) open pull request(s) in repository $repository" -ForegroundColor Green
    
} catch {
    Write-Host -ForegroundColor Red "Failed to list open pull requests: $($_.Exception.Message)"
    exit 1
}
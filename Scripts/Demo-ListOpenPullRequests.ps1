# Demo script for ListOpenPullRequests action
# This script demonstrates the expected output formats

Write-Host "Demo: ListOpenPullRequests Action" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This action provides a way to list all open pull requests for a GitHub repository." -ForegroundColor Green
Write-Host "It supports three output formats: table (default), list, and json." -ForegroundColor Green
Write-Host ""

Write-Host "Example of what the output would look like:" -ForegroundColor Yellow
Write-Host ""

Write-Host "TABLE FORMAT (default):" -ForegroundColor Cyan
Write-Host "======================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Open Pull Requests:" -ForegroundColor Green  
Write-Host "===================" -ForegroundColor Green
Write-Host ""
Write-Host "PR #   Title                                                    Author          Created      Draft"
Write-Host "----   -----                                                    ------          -------      -----"
Write-Host "1849   Warning to updateDependencies                           aholstrup1      2025-08-06   No   "
Write-Host "1844   [Draft] Add setting to choose which merge method to ... aholstrup1      2025-07-31   Yes  "
Write-Host "1839   Implementing tests for Deploy action                    spetersenms     2025-07-28   No   "

Write-Host ""
Write-Host "LIST FORMAT:" -ForegroundColor Cyan  
Write-Host "============" -ForegroundColor Cyan
Write-Host ""
Write-Host "Open Pull Requests:" -ForegroundColor Green
Write-Host "===================" -ForegroundColor Green
Write-Host ""
Write-Host "PR #1849: Warning to updateDependencies" -ForegroundColor Cyan
Write-Host "  Author: aholstrup1"
Write-Host "  Created: 2025-08-06 08:49:16"
Write-Host "  URL: https://github.com/microsoft/AL-Go/pull/1849"
Write-Host "  Description: Warning to updateDependencies..."
Write-Host ""
Write-Host "PR #1844: [Draft] Add setting to choose which merge method to use" -ForegroundColor Cyan
Write-Host "  Author: aholstrup1"  
Write-Host "  Created: 2025-07-31 10:00:36"
Write-Host "  URL: https://github.com/microsoft/AL-Go/pull/1844"
Write-Host "  Status: Draft" -ForegroundColor Yellow
Write-Host "  Description: Add setting to choose which merge method to use..."

Write-Host ""
Write-Host "JSON FORMAT:" -ForegroundColor Cyan
Write-Host "============" -ForegroundColor Cyan
Write-Host ""
Write-Host '[' -ForegroundColor Gray
Write-Host '  {' -ForegroundColor Gray
Write-Host '    "number": 1849,' -ForegroundColor Gray
Write-Host '    "title": "Warning to updateDependencies",' -ForegroundColor Gray
Write-Host '    "author": "aholstrup1",' -ForegroundColor Gray
Write-Host '    "created_at": "2025-08-06T08:49:16Z",' -ForegroundColor Gray
Write-Host '    "html_url": "https://github.com/microsoft/AL-Go/pull/1849",' -ForegroundColor Gray
Write-Host '    "draft": false' -ForegroundColor Gray
Write-Host '  },' -ForegroundColor Gray
Write-Host '  ...' -ForegroundColor Gray
Write-Host ']' -ForegroundColor Gray

Write-Host ""
Write-Host "Usage Examples:" -ForegroundColor Green
Write-Host "===============" -ForegroundColor Green
Write-Host ""
Write-Host "In a GitHub workflow:" -ForegroundColor Cyan
Write-Host "- name: List Open Pull Requests" -ForegroundColor Gray
Write-Host "  uses: ./Actions/ListOpenPullRequests" -ForegroundColor Gray
Write-Host "  with:" -ForegroundColor Gray
Write-Host "    token: `$`{ secrets.GITHUB_TOKEN }" -ForegroundColor Gray
Write-Host "    outputFormat: 'table'" -ForegroundColor Gray
Write-Host ""
Write-Host "From command line:" -ForegroundColor Cyan
Write-Host "./Actions/ListOpenPullRequests/ListOpenPullRequests.ps1 -repository 'microsoft/AL-Go'" -ForegroundColor Gray
Write-Host ""
Write-Host "The action automatically detects the current repository when running in GitHub Actions." -ForegroundColor Yellow
Write-Host "For private repositories or to avoid rate limits, provide a GitHub token." -ForegroundColor Yellow
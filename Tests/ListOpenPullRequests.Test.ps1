Get-Module TestActionsHelper | Remove-Module -Force
Import-Module (Join-Path $PSScriptRoot 'TestActionsHelper.psm1')
$errorActionPreference = "Stop"; $ProgressPreference = "SilentlyContinue"; Set-StrictMode -Version 2.0

Describe "ListOpenPullRequests Action Tests" {
    BeforeAll {
        $actionName = "ListOpenPullRequests"
        $scriptRoot = Join-Path $PSScriptRoot "..\Actions\$actionName" -Resolve
        $scriptName = "$actionName.ps1"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'scriptPath', Justification = 'False positive.')]
        $scriptPath = Join-Path $scriptRoot $scriptName
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'actionScript', Justification = 'False positive.')]
        $actionScript = GetActionScript -scriptRoot $scriptRoot -scriptName $scriptName
    }

    It 'Compile Action' {
        Invoke-Expression $actionScript
    }

    It 'Test action.yaml matches script' {
        $outputs = [ordered]@{
            "pr-count" = "Number of open pull requests found"
            "pr-list" = "JSON array of open pull requests"
        }
        YamlTest -scriptRoot $scriptRoot -actionName $actionName -actionScript $actionScript -outputs $outputs
    }

    It 'Test README.md exists' {
        $readmePath = Join-Path $scriptRoot "README.md"
        Test-Path $readmePath | Should -Be $true
    }

    It 'Test script has proper parameters' {
        $actionScript | Should -Match "Param\("
        $actionScript | Should -Match "token"
        $actionScript | Should -Match "repository"
        $actionScript | Should -Match "outputFormat"
    }

    It 'Test format functions are defined' {
        $actionScript | Should -Match "function GetOpenPullRequests"
        $actionScript | Should -Match "function FormatPullRequestsTable"
        $actionScript | Should -Match "function FormatPullRequestsList"
        $actionScript | Should -Match "function FormatPullRequestsJson"
    }

    It 'Test error handling is implemented' {
        $actionScript | Should -Match "try \{"
        $actionScript | Should -Match "catch \{"
        $actionScript | Should -Match "throw"
    }
}
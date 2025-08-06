# ListOpenPullRequests Action - Usage Guide

## Overview

The `ListOpenPullRequests` action is a new AL-Go action that provides an easy way to list all open pull requests for any GitHub repository. This action integrates seamlessly with the AL-Go framework and can be used both in GitHub Actions workflows and as a standalone PowerShell script.

## Features

- 📋 **Multiple Output Formats**: Table, List, and JSON formats
- 🔐 **Flexible Authentication**: Works with or without GitHub tokens
- 🔄 **GitHub Actions Integration**: Provides outputs for workflow integration
- ⚡ **Fast and Reliable**: Uses GitHub's REST API for accurate data
- 📊 **Rich Information**: Shows PR number, title, author, creation date, and draft status

## Quick Start

### In a GitHub Workflow

```yaml
name: Daily PR Report
on:
  schedule:
    - cron: '0 9 * * *'  # Run daily at 9 AM

jobs:
  pr-report:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: List Open PRs
        uses: ./Actions/ListOpenPullRequests
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          outputFormat: 'table'
```

### From Command Line

```powershell
# List PRs for current repository
./Actions/ListOpenPullRequests/ListOpenPullRequests.ps1

# List PRs for specific repository
./Actions/ListOpenPullRequests/ListOpenPullRequests.ps1 -repository 'microsoft/AL-Go'

# Get JSON output
./Actions/ListOpenPullRequests/ListOpenPullRequests.ps1 -repository 'owner/repo' -outputFormat 'json'
```

## Advanced Examples

### PR Count Monitoring

```yaml
- name: Monitor PR Count
  id: pr-check
  uses: ./Actions/ListOpenPullRequests
  with:
    token: ${{ secrets.GITHUB_TOKEN }}

- name: Alert on High PR Count
  if: steps.pr-check.outputs.pr-count > 10
  run: |
    echo "::warning::High number of open PRs detected: ${{ steps.pr-check.outputs.pr-count }}"
```

### Multi-Repository Monitoring

```yaml
- name: Check Multiple Repositories
  strategy:
    matrix:
      repo: ['microsoft/AL-Go', 'microsoft/AL-Go-PTE', 'microsoft/AL-Go-AppSource']
  uses: ./Actions/ListOpenPullRequests
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    repository: ${{ matrix.repo }}
    outputFormat: 'list'
```

### Integration with Slack/Teams

```yaml
- name: Get PR List
  id: prs
  uses: ./Actions/ListOpenPullRequests
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    outputFormat: 'json'

- name: Send to Slack
  uses: 8398a7/action-slack@v3
  with:
    status: custom
    custom_payload: |
      {
        text: "Open PRs Report",
        attachments: [{
          color: "good",
          fields: [{
            title: "PR Count",
            value: "${{ steps.prs.outputs.pr-count }}",
            short: true
          }]
        }]
      }
```

## Output Formats Explained

### Table Format (Default)
- Clean, readable table format
- Perfect for console output and workflow logs
- Shows essential information at a glance

### List Format
- Detailed view with descriptions
- Includes URLs and additional metadata
- Best for detailed analysis

### JSON Format
- Machine-readable structured data
- Perfect for integration with other tools
- Includes all available fields

## Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `token` | No | - | GitHub token for authentication |
| `repository` | No | Current repo | Repository in 'owner/repo' format |
| `outputFormat` | No | 'table' | Output format: 'table', 'list', or 'json' |

## Error Handling

The action provides clear error messages for common issues:

- **403 Forbidden**: Usually indicates missing authentication or rate limiting
- **404 Not Found**: Repository doesn't exist or isn't accessible
- **Network Issues**: Connection problems are properly reported

## Best Practices

1. **Use Tokens**: Always provide a GitHub token when possible to avoid rate limits
2. **Cache Results**: For frequent checks, consider caching the results
3. **Monitor Responsibly**: Don't run too frequently to avoid hitting API limits
4. **Handle Errors**: Use `continue-on-error: true` for non-critical workflows

## Integration with AL-Go

This action follows all AL-Go conventions:

- ✅ Uses AL-Go action patterns and structure
- ✅ Integrates with AL-Go telemetry system
- ✅ Follows PowerShell best practices
- ✅ Includes comprehensive tests
- ✅ Provides proper error handling

## Troubleshooting

### Rate Limiting
If you encounter rate limiting issues:
- Provide a valid GitHub token
- Reduce the frequency of API calls
- Use public repositories sparingly without authentication

### Private Repositories
To access private repositories:
- Always provide a GitHub token
- Ensure the token has appropriate permissions
- Use organization tokens for organization repositories

### Performance
For better performance:
- Use specific repository parameters instead of wildcards
- Cache results when checking multiple repositories
- Consider pagination for repositories with many PRs

## Contributing

This action is part of the AL-Go for GitHub project. To contribute:
1. Follow the AL-Go contribution guidelines
2. Add tests for any new functionality
3. Update documentation as needed
4. Ensure all existing tests pass
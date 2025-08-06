# List Open Pull Requests

This action lists all open pull requests for a GitHub repository.

## Inputs

### `token`
**Optional** - GitHub token for API authentication. If not provided, the action will attempt to list public pull requests without authentication.

### `repository`
**Optional** - Repository in the format 'owner/repo'. Defaults to the current repository when running in GitHub Actions.

### `outputFormat`
**Optional** - Output format for the results. Can be:
- `table` (default) - Displays results in a formatted table
- `list` - Displays results in a detailed list format
- `json` - Outputs results as JSON

## Outputs

### `pr-count`
The number of open pull requests found.

### `pr-list`
JSON array containing details of all open pull requests.

## Example Usage

### Basic usage (table format)
```yaml
- name: List Open Pull Requests
  uses: ./Actions/ListOpenPullRequests
```

### With authentication and specific repository
```yaml
- name: List Open Pull Requests
  uses: ./Actions/ListOpenPullRequests
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    repository: 'microsoft/AL-Go'
    outputFormat: 'list'
```

### Using outputs in subsequent steps
```yaml
- name: List Open Pull Requests
  id: list-prs
  uses: ./Actions/ListOpenPullRequests
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    outputFormat: 'json'

- name: Process PR count
  run: |
    echo "Found ${{ steps.list-prs.outputs.pr-count }} open pull requests"
```

## Output Formats

### Table Format (default)
Displays a clean table with columns: PR #, Title, Author, Created, Draft

### List Format
Displays detailed information for each pull request including:
- PR number and title
- Author
- Creation date
- URL
- Draft status
- Description (truncated)

### JSON Format
Returns structured JSON data suitable for processing by other tools or actions.

## Notes

- The action fetches up to 100 open pull requests per API call
- When running without authentication, only public repositories can be accessed
- Dates are displayed in the repository's timezone
- Long titles are truncated in table format for readability
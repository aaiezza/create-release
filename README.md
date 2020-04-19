# Create Release for Github Actions

Create a release from a specified branch

## Inputs

### `release_branch`

Branch to tag. Default `master`.

### `name`

The title of the release. Default `release: version ${TAG}`.

### `message`

The message of the release. Default generate conventional changelog.

### `draft`

Is a draft ?. Default `false`.

### `prerelease`

Is a pre-release ?. Default `false`.

### `create_release`

Create a new release ?. Default `true`.

### `tag`

Tag to use



## Output

### `release`

The new release name.

### `upload_url`
The URL for uploading assets to the release, which could be used by GitHub Actions for additional uses, for example the [`@actions/upload-release-asset`](https://www.github.com/actions/upload-release-asset) GitHub Action

## Example usage

```yaml
    steps:
      - uses: actions/checkout@v2.1.0

      - name: Create Release
        uses: aaiezza/create-release@master
        id: create_release
        with:
          release_branch: releases/0.0.1
          tag: 0.0.1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

     - name: Upload Jar
       uses: actions/upload-release-asset@v1.0.2
       env:
         GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
       with:
         upload_url: ${{ steps.create_release.outputs.upload_url }}
         asset_path: target/${{ needs.version.outputs.jar-name }}
         asset_name: ${{ needs.version.outputs.release-jar-name }}
         asset_content_type: application/java-archive
```


# Security Policy

## Supported versions

Only the latest release receives fixes. To update, download `Get-Recent-Adobe-Documents-For-LaunchBar.zip` from the [latest release](https://github.com/alberti42/Get-Recent-Adobe-Documents-For-LaunchBar/releases/latest) and install the actions again.

## Reporting a vulnerability

Report a vulnerability privately through GitHub: open the [Security tab](https://github.com/alberti42/Get-Recent-Adobe-Documents-For-LaunchBar/security) of this repository and choose **Report a vulnerability**. Do not open a public issue for a vulnerability.

Include the version of the action (`CFBundleVersion` in the action's `Contents/Info.plist`), the macOS version, and the steps to reproduce the problem.

## What the actions do that matters for security

- Each action runs one command-line tool, which reads one preferences file that the Adobe application writes:

  | Action | File | Entries read |
  |---|---|---|
  | Recent Acrobat Documents | `~/Library/Preferences/com.adobe.Acrobat.Pro.plist` | `DC` → `AVGeneral` → `RecentFiles` |
  | Recent Illustrator Documents | `~/Library/Preferences/com.adobe.mediabrowser.plist` | `MRU` → `illustrator` → `files` |
  | Recent Photoshop Documents | `~/Library/Preferences/com.adobe.mediabrowser.plist` | `MRU` → `Photoshop` → `files` |

  From each entry the tool takes the document's path, checks that the file still exists, and prints at most 50 documents (name, folder and path) as JSON to LaunchBar. It does not open the documents.
- The tools write no file and make no network connection. If a tool fails with an exception, it writes the exception message to the macOS system log.
- Each action in a release is built by GitHub Actions from the tagged source. Each `.lbaction` bundle, whose executable is the tool, is signed with a Developer ID with the hardened runtime and notarized by Apple. Gatekeeper fetches the notarization ticket online the first time you open an action. `Get-Recent-Adobe-Documents-For-LaunchBar.zip` carries a build provenance attestation. To check where a downloaded `Get-Recent-Adobe-Documents-For-LaunchBar.zip` was built:

  ```sh
  gh attestation verify Get-Recent-Adobe-Documents-For-LaunchBar.zip --repo alberti42/Get-Recent-Adobe-Documents-For-LaunchBar
  ```

  The attestation names the workflow (`.github/workflows/draft-release.yml`), the tag and the commit the ZIP was built from.
- To check a downloaded action before you install it:

  ```sh
  spctl --assess --type open --context context:primary-signature --verbose "Recent Photoshop Documents.lbaction"
  ```

  Gatekeeper answers `accepted` and `source=Notarized Developer ID`.

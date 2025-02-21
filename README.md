# Auto MSI Updater

## Description
This PowerShell script automates the process of downloading and updating MSI packages for software deployment via Group Policy Objects (GPO) in a domain environment. The script ensures that the latest version of specified software packages is always available by checking, downloading, and replacing outdated versions.

## Features
- Downloads the latest version of software MSI packages from provided links.
- Compares the newly downloaded version with the existing one.
- Replaces the existing MSI file if the new version is superior.
- Logs all actions in a `log.txt` file.

## Requirements
- Windows operating system with PowerShell enabled.
- A `packagesLinks.csv` file containing the software names and download links.
- Sufficient permissions to download and replace MSI files.

## Installation
1. Clone this repository or download the script.
2. Prepare the `packagesLinks.csv` file with the following format:
   ```csv
   SoftwareName,DownloadURL
   ExampleSoftware,https://example.com/latest.msi
   ```
3. Ensure the script has execution permissions:
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

## Usage
1. Run the script from PowerShell:
   ```powershell
   .\getPackages.ps1
   ```
2. The script will download and update MSI files as needed.
3. Check `log.txt` for details on executed actions.

## Logging
All actions performed by the script, including downloads, comparisons, and replacements, are recorded in a `log.txt` file. This log file helps track updates and troubleshoot any issues.

## License
This project is licensed under the MIT License.

## Contributing
Feel free to fork this repository, submit issues, or propose improvements.

## Author
sudoPierre


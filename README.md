Windows Batch Script for File Analysis

This Windows Batch script is designed to analyze files in the C: directory, identify suspicious files listed in suspicious_files.txt, and save the results in a text file 'output.txt' newly created directory named as "username_hostname".

Features

1) Time Display: The script displays the start time and end time on the console.
2) Directory Creation: Creates a directory named "username_hostname" to store the analysis results.
3) File path Copy: Copies the full path suspicious files to a text file in the newly created directory.
4) File Extraction: Extracts all file paths in the C: directory and writes them to allfiles.txt.
5) Substring Matching: Matches file paths containing substrings from the list of suspicious files and saves the results in output.txt.
6) Sanitization: Removes false positives by comparing results with the list of substrings.

Usage

1) Ensure that the script is run with administrative privileges.
2) Customize the suspicious_files.txt with the list of files to be flagged.
3) Run the script, and it will create a directory, copy files, and perform the analysis.

Prerequisites

1) Windows environment
2) Administrative privileges for file access and execution

Instructions
1) Add the suspicious files to be checked in suspicious_files.txt. e.g. 7z.exe, malware.exe
2) Run the bat file 'scan.bat' with admin priveleges
3) It will create a directory having username & hostname.
4) In the same folder output.txt file will contain the matching results.

Results

The analyzed results are saved in the newly created directory, and the final output is stored in output.txt.

License

This project is licensed under the MIT License.

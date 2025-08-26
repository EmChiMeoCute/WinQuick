Explanation

This project contains two small PowerShell scripts: WinQuick and Update. They are designed to save time when installing or updating applications on Windows. Both scripts use Microsoft’s winget package manager, but instead of requiring you to type long commands into the terminal, they give you a simple graphical interface.

WinQuick is used when you want to install new applications. Normally, installing software with winget requires commands like:

winget install --id Google.Chrome


With WinQuick, you just open the script, check the boxes for the applications you want (for example Chrome, Discord, OBS Studio, Spotify, or Visual Studio Code), and press the Install button. The script runs the correct commands for you. You can select multiple apps at once, so it is very helpful when setting up a new computer.

Update is used when you want to keep your apps up to date. Instead of typing winget upgrade and updating each app one by one, Update scans your system and shows you a list of applications with new versions available. You can then choose which ones to update. There are also buttons for “Select All” and “Clear All” so you do not have to click every box manually. After you make your selection, click Update and the script will upgrade the apps and show you the results in a log window.

The benefit of these scripts is that they are fast, easy to use, and require no setup. You can run them directly from PowerShell with a single command. For example:

Run WinQuick (to install apps):

irm https://gist.githubusercontent.com/EmChiMeoCute/e02b78971f454162757c101a5f767d79/raw/WinQuick.ps1 | iex


Run Update (to check and update apps):

irm https://gist.githubusercontent.com/EmChiMeoCute/72dcf8bec48c0eea29bd403c65477d65/raw/Update.ps1 | iex


In short, WinQuick helps you install applications quickly, and Update helps you update them just as easily. This makes managing software on Windows much faster and more convenient, especially if you reinstall often or maintain multiple computers.

# winfetch
neofetch for windows


### Description: 
Winfetch is a tool written in powershell that displays your system info in a visually pleasing way, it doesn't have any purpose...and is just for aesthetics.
 
<img width="690" alt="image" src="https://github.com/Priyanshu-1012/winfetch/assets/39450902/9e0f691f-ca80-43f8-83c2-6a4ba6412303">

‎ 
‎ 



<img width="517" alt="image" src="https://github.com/Priyanshu-1012/winfetch/assets/39450902/fc2ea60b-7a75-474f-9183-53e9c8684da5">

### Installation

_Note: wherever the command says ~/Documents you can go on and type your preffered location._

1. Open Powershell and type/paste the following command
   ```powershell
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Priyanshu-1012/winfetch/master/winfetch.ps1" | Select-Object -ExpandProperty Content | Out-File -FilePath ~/Documents/winfetch.ps1 -Encoding UTF8
   ```
2. Next, paste the following command on terminal.
   ```powershell
   "function winfetch {
       `$scriptPath = Resolve-Path -Path '~/Documents/winfetch.ps1'
       & `$scriptPath
   }" | Add-Content $profile
   ```
   
3. Run the command ```pwsh``` on the same terminal to relaunch powershell
4. Now you can try and run ```winfetch``` command on terminal.

*Powershell 7 and nerdfonts are recommended*


i know it needs work...and i'll work on it

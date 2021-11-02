git clone https://github.com/aodetallah1988/Scipt-to-remove-windows-bloatware.git

cd Scipt-to-remove-windows-bloatware

Set-ExecutionPolicy Unrestricted -Force

.\Windows10SysPrepDebloater.ps1 -Debloat

cd ..

Remove-Item -Path . -Include Scipt-to-remove-windows-bloatware -Recurse
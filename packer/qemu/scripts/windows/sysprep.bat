rem net stop tiledatamodelsvc
echo "I am shutting down"

rem c:\windows\system32\sysprep\sysprep.exe /generalize /mode:vm /oobe /unattend:a:\unattend.xml
rem shutdown /s

powershell -NoProfile -ExecutionPolicy unrestricted -Command "GCESysprep -unattended a:\unattend.xml"

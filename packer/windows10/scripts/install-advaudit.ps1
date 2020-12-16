Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-WebRequest "https://www.malwarearchaeology.com/s/Set_Adv_Auditing_Folders_Keys_vDec_2018-fa6n.zip" -OutFile "C:\Users\vagrant\audit.zip"

cd "C:\Users\vagrant\"

Expand-Archive -LiteralPath "C:\Users\vagrant\audit.zip" -DestinationPath "C:\Users\vagrant\audit"

cd "C:\Users\vagrant\audit"

.\1_Set_Audit_Pol_PS_v2_3_4_5.cmd

.\2_Set_User_Folder_Auditing_v2.cmd

.\3_Set_User_Registry_Auditing.cmd

.\Set_User_Registry_Auditing.ps1


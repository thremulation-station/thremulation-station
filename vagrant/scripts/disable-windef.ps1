Set-MpPreference -DisableRealtimeMonitoring $true

Set-MpPreference -DisableBehaviorMonitoring $true

netsh advfirewall set allprofiles state off




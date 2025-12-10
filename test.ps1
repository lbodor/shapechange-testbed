#!/usr/bin/env pwsh

$headers = @{ 'user-agent' = 'x'; 'sec-fetch-site' = 'x' }

Invoke-WebRequest -Uri https://sparxsystems.com/bin/ealite_x64.msi -SkipHttpErrorCheck -Headers $headers -Debug

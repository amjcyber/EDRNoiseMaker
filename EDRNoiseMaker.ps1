function Install-ModuleIfNeeded {
    param(
        [string]$moduleName
    )

    if (-not (Get-Module -ListAvailable -Name $moduleName)) {
        try {
            Install-Module -Name $moduleName -Force -Scope CurrentUser -ErrorAction Stop
        } 
        catch {
            Write-Error "Failed to install module '$moduleName': $_"
            return $false
        }
    }

    return $true
}

function Get-WfpFilterData {
    param (
        [string[]]$executables
    )

    $wfp_filter = Get-FwFilter | Where-Object { $_.ActionType -eq "Block" }
    $result = @()

    foreach ($filter in $wfp_filter) {
        $filter_fw = $filter | Format-FwFilter
        foreach ($exe in $executables) {
            if ($filter_fw | Select-String $exe) {
                $filtered_executable = $filter.Conditions.Value.ContextValue         
                $filter_id = $filter.FilterId  
                $filter_action_type = $filter.ActionType
                $filter_name = $filter.Name

                $result += [PSCustomObject]@{
                    "Executable" = $filtered_executable
                    "Id" = $filter_id.ToString()
                    "ActionType" = $filter_action_type.ToString()
                    "Name" = $filter_name
                }
            }
        }
    }

    return $result
}

# Main Script
$moduleName = "NtObjectManager"

if (-not (Install-ModuleIfNeeded -moduleName $moduleName)) {
    Write-Error "Failed to install the required module '$moduleName'. Exiting."
    exit 1
}

Import-Module -Name $moduleName

$executables = @(
    "MsMpEng.exe",
    "MsSense.exe",
    "SenseIR.exe",
    "SenseNdr.exe",
    "SenseCncProxy.exe",
    "SenseSampleUploader.exe",
    "elastic-agent.exe",
    "elastic-endpoint.exe",
    "filebeat.exe",
    "xagt.exe",
    "QualysAgent.exe",
    "SentinelAgent.exe",
    "SentinelAgentWorker.exe",
    "SentinelServiceHost.exe",
    "SentinelStaticEngine.exe",  
    "LogProcessorService.exe",
    "SentinelStaticEngineScanner.exe",
    "SentinelHelperService.exe",
    "SentinelBrowserNativeHost.exe",
    "CylanceSvc.exe",
    "AmSvc.exe",
    "CrAmTray.exe",
    "CrsSvc.exe",
    "ExecutionPreventionSvc.exe",
    "CybereasonAV.exe",
    "cb.exe",
    "RepMgr.exe",
    "RepUtils.exe",
    "RepUx.exe",
    "RepWAV.exe",
    "RepWSC.exe",
    "TaniumClient.exe",
    "TaniumCX.exe",
    "TaniumDetectEngine.exe",
    "Traps.exe",
    "cyserver.exe",
    "CyveraService.exe",
    "CyvrFsFlt.exe",
    "fortiedr.exe",
    "sfc.exe"
    )
$result = Get-WfpFilterData -executables $executables
if ($result) {
    $result
}
else {
    Write-Output "No blocked executables from the list"
}

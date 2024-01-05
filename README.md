# EDRNoiseMaker
Detect WFP filters blocking EDR communications

The aim of this tool is to detect potential silencers of an EDR (or the process you choose). Based on the attack against EDR developed by [EDRSilencer](https://github.com/netero1010/EDRSilencer) and [FireBlock](https://www.mdsec.co.uk/2023/09/nighthawk-0-2-6-three-wise-monkeys/), `EDRNoiseMaker` trys to detect them by checking a list of executables that have been *silenced* using the Windows Filtering Platform (WFP).

## WFP
The Windows Filtering Platform (WFP) is a set of application programming interfaces (APIs) and system services provided by Microsoft in Windows operating systems. It is a comprehensive networking platform that allows developers to implement custom network security solutions, packet filtering, and network monitoring applications.
With WFP you are able to block network connections of a process without a very limited footprint: No registry keys, no rules added to Windows Firewall and no by default Events. This makes it a really nice approach to cut communications between EDR and the cloud console making analyst blind to what is happening there.

## Detection approach
There is no native way to list and interact with WFP. To do that we need to use the [NtObjectManager](https://www.powershellgallery.com/packages/NtObjectManager/2.0.1) module.

With the help of `NtObjectManager` we will be able to list all filters and the approach will be:
- Create a list with the executables you want to check
- Listed filters that block connections
- Filter that list by the executables provided

The actual executable list is based on the list provided by [EDRSilencer](https://github.com/netero1010/EDRSilencer):
```
"MsMpEng.exe","MsSense.exe","SenseIR.exe","SenseNdr.exe","SenseCncProxy.exe","SenseSampleUploader.exe","elastic-agent.exe","elastic-endpoint.exe","filebeat.exe","xagt.exe","QualysAgent.exe","SentinelAgent.exe", "SentinelAgentWorker.exe","SentinelServiceHost.exe","SentinelStaticEngine.exe",  "LogProcessorService.exe","SentinelStaticEngineScanner.exe","SentinelHelperService.exe","SentinelBrowserNativeHost.exe","CylanceSvc.exe","AmSvc.exe","CrAmTray.exe","CrsSvc.exe","ExecutionPreventionSvc.exe","CybereasonAV.exe","cb.exe","RepMgr.exe","RepUtils.exe","RepUx.exe","RepWAV.exe","RepWSC.exe","TaniumClient.exe","TaniumCX.exe","TaniumDetectEngine.exe","Traps.exe","cyserver.exe","CyveraService.exe","CyvrFsFlt.exe","fortiedr.exe","sfc.exe"
```
Add executables as you need.

## Testing

For testing pruposes we will block the built in Microsoft Defender Antivirus `MsMpEng.exe`:

```
.\EDRSilencer.exe block "C:\Program Files\Windows Defender\MsMpEng.exe"
```

Then we execute `EDRNoiseMaker.ps1` and we get:
```
Executable                                                         Id     ActionType Name
----------                                                         --     ---------- ----
\device\harddiskvolume3\program files\windows defender\msmpeng.exe 324367 Block      Custom Outbound Filter
\device\harddiskvolume3\program files\windows defender\msmpeng.exe 324368 Block      Custom Outbound Filter
```

To remove the filters:
```
Import-Module NtObjectManager
$engine = Get-FwEngine
Remove-FwFilter -Engine $engine -Id <Id>
```

## Sources
I couldn't make this without this resources:
- [What The Filter (WTF) is Going on With Windows Filtering Platform (WFP)?](https://zeronetworks.com/blog/wtf-is-going-on-with-wfp/)
- [EDRSilencer](https://github.com/netero1010/EDRSilencer)
- [NtObjectManager](https://github.com/googleprojectzero/sandbox-attacksurface-analysis-tools/tree/main/NtObjectManager)
- [CRWD-HBFW](https://github.com/cs-shadowbq/CRWD-HBFW/tree/main)

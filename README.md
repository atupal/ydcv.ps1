# ydcv.ps1
PowerShell version [ydcv](https://github.com/felixonmars/ydcv)

## usage

Copy the *ydcv* module to `$env:PSModulePath`.
Bellow is a example of directory layout
```
C:\Users\username\Documents\WindowsPowerShell
└───Modules
    ├───PsGet
    ├───PSReadLine
    │   └───en-US
    └───ydcv
    │   └───ydcv.psm1
    │   └───README
```

Use the module:
```
Import-Module ydcv
```

Or add this line to `C:\Users\username\Documents\WindowsPowerShell\profile.ps1`

Example screenshot:

![ydcv](https://cloud.githubusercontent.com/assets/1540389/10358659/2a4aea38-6dc3-11e5-9bf2-3a04693409f0.JPG)

### other commands
```
sw queryword    # query the word and speak it
speak word      # speak the word
```

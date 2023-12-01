@{
    RootModule = 'RootModule.psm1'
    ModuleVersion = '0.0.1'
    CompatiblePSEditions = @('Core')
    GUID = '40a3cf20-f495-4cf9-84c8-1e1a11f3ce46'
    Author = 'Tom Cousins'
    CompanyName = ''
    Copyright = '(c) Tom Cousins. All rights reserved.'
    Description = 'A collection of utilities for working with FreshService'
    PowerShellVersion = '7.3'
    RequiredModules = @()
    
    ScriptsToProcess = @()
    
    FunctionsToExport = @(
        'Get-FreshAsset'
        'Set-FreshAsset'
        'Get-FreshUser'
        'Invoke-FreshRequest'
        'Add-FreshTask'
        'Get-FreshLocation'
        'Get-FreshLocationHierarchy'
    )
    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @(
        'fresh'
    )
    
    PrivateData = @{
        PSData = @{}
    }
}


Set-StrictMode -Version '3.0'
$ErrorActionPreference = 'Stop' # Stop|Inquire|Continue|Suspend|SilentlyContinue


. "$PSScriptRoot/Private/Helpers.ps1"
. "$PSScriptRoot/Private/fresh_cache.ps1"

(Get-ChildItem "$PSScriptRoot/Commands").ForEach({. "$_"})

Set-Alias -Name fresh -Value Invoke-FreshRequest -Force







#&{
#$pattern = @"
#(?sx)
#(?<entry>
#    <div\s+class=api-url>\s*?
#        <i\s+class="label\s.*?">
#            (?<method>.*?)
#        </i>\s*
#        <span\s+.*?>.*?</span>\s*
#        <h6>\s*
#            (?<endpoint>/*api/v2/[^\s?]+?)\s*
#        </h6>\s*
#    </div>
#)
#"@
#    
#    $apidata = (Invoke-RestMethod 'https://api.freshservice.com')
#
#    [regex]::Matches($apidata, $pattern).ForEach({
#        [pscustomobject]@{
#            Endpoint = $_.Groups['endpoint'].Value
#            Method = $_.Groups['method'].Value
#            Hash = ''
#        }
#    }).ForEach({
#        $_.Endpoint = $_.Endpoint.StartsWith('/') ? $_.Endpoint : "/$($_.Endpoint)"
#        $_.Endpoint = $_.Endpoint.Replace('[','${').Replace(']','}').TrimEnd('/ ')
#        $_.Hash = ($_.Endpoint + $_.Method).GetHashCode()
#        $_
#    }) |
#    Sort-Object -Property Hash -Unique |
#    Sort-Object -Property Endpoint |
#    Set-Variable -Name "valid_fresh_endpoints" -Scope 'Script' # -Option 'Constant'  -Visibility 'Private'
#}
#
#Register-ArgumentCompleter -CommandName 'fresh_get' -ParameterName 'Endpoint' -ScriptBlock {
#    # Param($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameters)
#    # "The names of the parameters aren't important because PowerShell passes in the values by position"
#    # use $args instead of params so there are no annoying warnings
#    $WordToComplete = $args[2]
#    $valid_fresh_endpoints.Where({
#        $_.Endpoint.Contains("$($WordToComplete.Trim('"'))")
#    }).ForEach({
#        [String]::Format('"{0}"', $_.Endpoint)
#    })
#}
#
#Register-ArgumentCompleter -CommandName 'Invoke-FreshRequest' -ParameterName 'Endpoint' -ScriptBlock {
#    # Param($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameters)
#    # "The names of the parameters aren't important because PowerShell passes in the values by position"
#    # use $args instead of params so there are no annoying warnings
#    $WordToComplete = $args[2]
#    $FakeBoundParams = $args[4]
#    $valid_fresh_endpoints.Where({
#        $_.Endpoint.Contains("$($WordToComplete.Trim('"'))") -and
#        $_.Method -eq $FakeBoundParams['Method']
#    }).ForEach({
#        [String]::Format('"{0}"', $_.Endpoint)
#    })
#}




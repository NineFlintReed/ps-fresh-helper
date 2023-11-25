function Set-FreshAsset {
    [CmdletBinding()]
    Param(
        [Alias('display_id')]
        [Parameter(Position=0,Mandatory)]
        [ValidateRange("Positive")]
        [Int64]$DisplayId,
        
        [ValidateNotNullOrEmpty()]
        [String]$User,
        
        [Alias('name')]
        [ValidateNotNullOrEmpty()]
        [String]$AssetName,
        
        [Alias('asset_type_id')]
        [ValidateRange("Positive")]
        [Int64]$AssetTypeId,
        
        [ValidateNotNullOrEmpty()]
        [String]$Description,
        
        [Alias('usage_type')]
        [ValidateSet('Permanent','Loaner')]
        [String]$UsageType,
        
        [ValidateSet('Low','Medium','High')]
        [String]$Impact
        
        #[Alias('location_id')]
        #[ValidateNotNullOrEmpty()]
        #[String]$Location,
        
        #[Alias('department_id')]
        #[ValidateNotNullOrEmpty()]
        #[String]$Department,
        
        #[Alias('group_id')]
        #[ValidateNotNullOrEmpty()]
        #[String]$Group
    )

    process {
        $params = @{
            Method = 'PUT'
            Endpoint = "/api/v2/assets/${DisplayId}"
            Body = @{}
        }

        if($PSBoundParameters.ContainsKey('User')) {
            $params.Body['user_id'] = switch($User) {
                {$_ -as [Uint64]}      { $User                          }
                {$_ -as [MailAddress]} { (Get-FreshUser -User $User).id }
            }
        }
        
        if($PSBoundParameters.ContainsKey('AssetName')) {
            $params.Body['name'] = $AssetName
        }
        
        if($PSBoundParameters.ContainsKey('AssetTypeId')) {
            $params.Body['asset_type_id'] = $AssetTypeId
        }

        if($PSBoundParameters.ContainsKey('Description')) {
            $params.Body['description'] = $Description
        }
        
        if($PSBoundParameters.ContainsKey('UsageType')) {
            $params.Body['usage_type'] = $UsageType
        }

        if($PSBoundParameters.ContainsKey('Impact')) {
            $params.Body['impact'] = $Impact
        }

        Invoke-FreshRequest @params |
        Select-Object -ExpandProperty 'asset'
    }
}
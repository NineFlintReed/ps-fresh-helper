function Get-FreshAsset {
    [CmdletBinding(DefaultParameterSetName='List')]
    Param(
        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='Single')]
        [String]$DisplayId,

        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='List')]
        [String]$AssetTag,
        
        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='List')]
        [String]$AssetName,

        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='List')]
        [String]$User,

        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='List')]
        [String]$Search,

        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='List')]
        [Uint64]$LocationId,

        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='List')]
        [String]$AssetType,

        [ValidateNotNullOrEmpty()]
        [String]$Workspace,

        [Switch]$IncludeTypeFields

    )

    $params = @{
        Method = 'GET'
        Body = @{}
        Endpoint = switch($PSCmdlet.ParameterSetName) {
            'List'   { "/api/v2/assets"            }
            'Single' { "/api/v2/assets/$DisplayId" }
        }
    }

    $filter_terms = switch($PSBoundParameters.Keys) {
        'AssetTag'  { "asset_tag:'$AssetTag'" }
        'AssetName' { "name:'$AssetName'" }
        'Location'  { "location_id:$LocationId" }
        'AssetType' {
            "asset_type_id:{0}" -f (Get-FreshAssetType -AssetType $AssetType -IncludeHidden).id
        }
        'User' {
            switch($User) {
                {$_ -as [UInt64]}       { "user_id:{0}" -f $User                                    }
                {$_ -as [MailAddress]}  { "user_id:{0}" -f (Get-FreshUser -User $User -UseCache).id }            
            }
        }
    }

    if($filter_terms) {
        $params.Body['filter'] = '"{0}"' -f ($filter_terms -join ' AND ')
    }

    if($IncludeTypeFields) {
        $params.Body['include'] = 'type_fields'
    }

    if($PSBoundParameters.ContainsKey('Search')) {
        $params.Body['search'] = '"name:{0}"' -f "'$Search'"
    }

    if($PSBoundParameters.ContainsKey('Workspace')) {
        $params.Body['workspace_id'] = (Get-FreshWorkspace -Workspace $Workspace).id
    }

    Write-Debug "Get-FreshAsset: Fetching using filter: $($params.Body['filter'])"
    Invoke-FreshRequest @params |
    Select-Object -ExpandProperty 'asset*'
}
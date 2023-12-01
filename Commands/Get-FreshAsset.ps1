function Get-FreshAsset {
    [CmdletBinding(DefaultParameterSetName='All')]
    Param(
        [ValidateNotNullOrEmpty()]
        [Parameter(Position=0,ParameterSetName='AssetTag')]
        [String]$AssetTag,

        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='DisplayId')]
        [String]$DisplayId,
        
        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='AssetName')]
        [String]$AssetName,

        [Alias('user_id')]
        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='User',ValueFromPipelineByPropertyName)]
        [String]$User,

        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='Search')]
        [String]$Search,

        [Switch]$IncludeTypeFields,

        [Int]$WorkspaceId
    )

    process {
        $params = @{
            Method = 'GET'
            Endpoint = "/api/v2/assets"
            Body = @{}
        }

        switch($PSCmdlet.ParameterSetName) {
            'DisplayId' { $params.Endpoint += "/$DisplayId"                           }
            'AssetTag'  { $params.Body['filter'] = '"asset_tag:{0}"' -f "'$AssetTag'" }
            'User' {
                $params.Body['filter'] = switch($User) {
                    {$_ -as [Int64]}       { '"user_id:{0}"' -f (Get-FreshUser -User $_).id }
                    {$_ -as [MailAddress]} { '"user_id:{0}"' -f (user_email_to_id $User)    }
                }             
            }
            'AssetName' { $params.Body['filter'] = '"name:{0}"' -f "'$AssetName'"     }
            'Search'    { $params.Body['search'] = '"name:{0}"' -f "'$Search'"        }
            'All'       { }
        }

        if($IncludeTypeFields) {
            $params.Body['include'] = 'type_fields'
        }
        if($PSBoundParameters.ContainsKey('WorkspaceId')) {
            $params.Body['workspace_id'] = $WorkspaceId
        }

        Invoke-FreshRequest @params |
        Select-Object -ExpandProperty 'asset*'
    }
}
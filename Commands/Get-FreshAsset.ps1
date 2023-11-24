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
        [Parameter(ParameterSetName='UserId',ValueFromPipelineByPropertyName)]
        [String]$UserId,


        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='Search')]
        [String]$Search,

        [Switch]$IncludeTypeFields
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
            'UserId'    { $params.Body['filter'] = '"user_id:{0}"' -f "$UserId"       }
            'AssetName' { $params.Body['filter'] = '"name:{0}"' -f "'$AssetName'"     }
            'Search'    { $params.Body['search'] = '"name:{0}"' -f "'$Search'"        }
            'All'       { }
        }

        if($IncludeTypeFields) {
            $params.Body['include'] = 'type_fields'
        }

        Invoke-FreshRequest @params |
        Select-Object -ExpandProperty 'asset*'
    }
}
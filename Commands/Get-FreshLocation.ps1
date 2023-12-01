function Get-FreshLocation {
    [CmdletBinding(DefaultParameterSetName='All')]
    Param(
        [Alias('location_id')]
        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='Location',ValueFromPipelineByPropertyName)]
        $Location
    )

    process {
        $params = @{
            Method = 'GET'
            Endpoint = "/api/v2/locations"
            Body = @{ }
        }

        
        switch($PSCmdlet.ParameterSetName) {
            'Location' {
                switch($Location) {
                    {$_ -as [Int64]} {
                        $params.Endpoint += "/$Location"
                        break
                    }
                    {$_ -is [String]} {
                        $params.Body['query'] = "name:'$Location'"
                        break
                    }
                    default {
                        throw "Invalid parameter 'Location': '$Location' must be an id or name."
                    }
                }
            }
            'All' {
                $params.Body['per_page'] = 100
            }
        }

        Invoke-FreshRequest @params |
        Select-Object -ExpandProperty 'location*'
    }
}
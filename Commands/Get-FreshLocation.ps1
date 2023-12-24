function Get-FreshLocation {
    [CmdletBinding(DefaultParameterSetName='All')]
    Param(
        [Alias('location_id')]
        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='Location',ValueFromPipelineByPropertyName)]
        [UInt64]$Location,

        [Parameter(ParameterSetName='Location')]
        [Switch]$IncludeChildren,

        [Parameter(ParameterSetName='RootLocationsOnly')]
        [Switch]$RootLocationsOnly
    )

    process {
        $params = @{
            Method = 'GET'
            Endpoint = "/api/v2/locations"
            Body = @{ }
        }

        switch($PSCmdlet.ParameterSetName) {
            'All' {
                $params.Body['per_page'] = 100
                Invoke-FreshRequest @params | Select-Object -ExpandProperty 'location*'
            }
            'RootLocationsOnly' {
                $params.Body['per_page'] = 100
                Invoke-FreshRequest @params | Select-Object -ExpandProperty 'location*' |
                Where-Object {
                    $null -eq $_.parent_location_id
                }
            }
            'Location' {
                if($IncludeChildren) {
                    $params.Body['per_page'] = 100
                    $location_listing = (Invoke-FreshRequest @params).locations
                    $root = $location_listing.Where({$_.id -eq $Location})
                    if(-not $root) {
                        throw "No location found with id '$Location'"
                    }

                    $todo = [System.Collections.Generic.Stack[Object]]::new()
                    $todo.Push($root)

                    while ($todo.Count -gt 0) {
                        $current = $todo.Pop()
                        $location_listing |
                        Where-Object {
                            $_.parent_location_id -eq $current.id
                        } |
                        ForEach-Object {
                            $todo.Push($_)
                        }
                        $current
                    }
                } else {
                    $params.Endpoint += "/$Location"
                    Invoke-FreshRequest @params | Select-Object -ExpandProperty 'location*'
                }
            }
        }
    }
}
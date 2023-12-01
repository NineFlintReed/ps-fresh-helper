function Get-FreshUser {
    [CmdletBinding(DefaultParameterSetName='All')]
    Param(        
        [Alias('primary_email','user_id','id')]
        [ValidateNotNullOrEmpty()]
        [Parameter(Position=0,ParameterSetName='User',ValueFromPipelineByPropertyName)]
        [String]$User,

        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='Search')]
        [String]$Search
    )

    process {
        $params = @{
            Method = 'GET'
            Endpoint = "/api/v2/requesters"
            Body = @{
                include_agents='true'
            }
        }
        
        switch($PSCmdlet.ParameterSetName) {
            'User' {
                switch($User) {
                    {$_ -as [Int64]             } { $params.Endpoint += "/$User"  }
                    {$_ -as [MailAddress]       } { $params.Body['email'] = $User }
                    {[String]::IsNullOrEmpty($_)} { } # default all, no change
                    default {
                        throw "Invalid parameter 'User': '$User' must be id or email."
                    }
                }
            }
            'Search' {
                # despite saying email, filters by firstname and lastname as well. the query syntax for requesters kindof sucks
                $params.Body['query'] = "~[primary_email]:'$Search'"
            }
        }

        &{
            if($PSCmdlet.ParameterSetName -eq 'User') {
                $result = Invoke-FreshRequest @params |
                Select-Object -ExpandProperty 'requester*'
                if(-not $result) {
                    Write-Error -Message "User email '$User' not found." -ErrorAction 'Stop' -Category ObjectNotFound
                } else {
                    $result
                }
            } else {
                Invoke-FreshRequest @params |
                Select-Object -ExpandProperty 'requester*'
            }
        } |
        ForEach-Object {
            $FreshCache.Requesters[$_.primary_email] = $_.id
            $_
        }
    }
}

function Get-FreshUser {
    [CmdletBinding(DefaultParameterSetName='All')]
    Param(        
        [Alias('primary_email','user_id','id')]
        [ValidateNotNullOrEmpty()]
        [Parameter(Position=0,ParameterSetName='User',ValueFromPipelineByPropertyName)]
        [String]$User 
    )

    process {
        $params = @{
            Method = 'GET'
            Endpoint = "/api/v2/requesters"
            Body = @{
                include_agents='true'
            }
        }
        
        switch($User) {
            {$_ -as [Int64]             } { $params.Endpoint += "/$User"  }
            {$_ -as [MailAddress]       } { $params.Body['email'] = $User }
            {[String]::IsNullOrEmpty($_)} { } # default all, no change
            default {
                throw "Invalid parameter 'User': '$User' must be id or email."
            }
        }

        Invoke-FreshRequest @params |
        Select-Object -ExpandProperty 'requester*'
    }
}
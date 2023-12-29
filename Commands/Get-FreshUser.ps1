function Get-FreshUser_ViaId {
    Param($user_id)
    $params = @{
        Method = 'GET'
        Endpoint = "/api/v2/requesters/$user_id"
        Body = @{
            include_agents='true'
        }
    }
    $result = (Invoke-FreshRequest @params).requester
    add_user_cached $result
    $result
}


function Get-FreshUser_ViaEmail {
    Param($email)
    $params = @{
        Method = 'GET'
        Endpoint = "/api/v2/requesters"
        Body = @{
            email = $email
            include_agents='true'
        }
    }
    $result = (Invoke-FreshRequest @params).requesters
    if(-not $result) {
        Write-Error -Message "User email '$email' not found." -ErrorAction 'Stop' -Category ObjectNotFound
    }
    add_user_cached $result
    $result
}


function Get-FreshUser_All {
    $params = @{
        Method = 'GET'
        Endpoint = "/api/v2/requesters"
        Body = @{
            include_agents='true'
            per_page = 100
        }
    }
    Invoke-FreshRequest @params |
    Select-Object -ExpandProperty requesters |
    ForEach-Object {
        add_user_cached $_
        $_
    }
}


function Get-FreshUser_Search {
    Param($searchterm)
    $params = @{
        Method = 'GET'
        Endpoint = "/api/v2/requesters"
        Body = @{
            # despite saying email, filters by firstname and lastname as well. the query syntax for requesters kindof sucks
            query = "~[primary_email]:'$searchterm'"
            include_agents='true'
            per_page = 100
        }
    }

    Invoke-FreshRequest @params |
    Select-Object -ExpandProperty requesters |
    ForEach-Object {
        add_user_cached $_
        $_
    }
}


function Get-FreshUser {
    [CmdletBinding(DefaultParameterSetName='All')]
    Param(
        [ValidateNotNullOrEmpty()]
        [Parameter(Position=0,ParameterSetName='User')]
        [String]$User,

        [Parameter(ParameterSetName='User')]
        [Switch]$UseCache,

        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='Search')]
        [String]$Search
    )
    
    switch($PSCmdlet.ParameterSetName) {
        'User' {
            if($UseCache -and (get_user_cached $user)) {
                get_user_cached $user
            } else {
                switch($User) {
                    {$_ -match '^\d+$'} {
                        Get-FreshUser_ViaId $User
                    }
                    {[MailAddress]::TryCreate($_, [ref]$null)} {
                        Get-FreshUser_ViaEmail $User
                    }
                    default {
                        Write-Error "'$($User.GetType())' invalid for param 'User'. Must use either ID or email" -ErrorAction Stop -Category InvalidArgument
                    }
                }
            }
        }
        'Search' {
            Get-FreshUser_Search $Search
        }
        'All' {
            Get-FreshUser_All
        }
    }
}
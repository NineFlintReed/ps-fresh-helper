

function params_to_query_string {
    Param(
        $Body
    )
    $result = [Web.HttpUtility]::ParseQueryString('')

    if($null -eq $Body) {
        Write-Output $result -NoEnumerate
        return
    }
    if($Body -is [String]) {
        $is_json = Test-Json -Json $Body -ErrorAction SilentlyContinue
        if($is_json) {
            $Body = ConvertFrom-Json $Body -AsHashtable
        } else {
            $result.Add([Web.HttpUtility]::ParseQueryString($Body))
            Write-Output $result -NoEnumerate
            return
        }
    }

    if($Body -is [PSObject]) {
        $Body = ConvertTo-Json $Body | ConvertFrom-Json -AsHashtable
    }

    if($Body -is [Collections.IList]) {
        foreach($item in $Body) {
            $result.Add([Web.HttpUtility]::ParseQueryString($item))
        }
    }

    # @{ thing = @(1,2,3)} -> thing=1&thing=2&thing=3
    if($Body -is [Collections.IDictionary]) {
        foreach($kv in $Body.GetEnumerator()) {
            if($kv.Value -is [Collections.IList]) {
                foreach($item in $kv.Value) {
                    $result.Add($kv.Key, $item)
                }
            } else {
                $result.Add($kv.Key, $kv.Value)
            }
        }
    }

    Write-Output $result -NoEnumerate
}


function fresh_get {
    [CmdletBinding()]
    Param(
        $Endpoint,
        $Body
    )

    # if well formed, assume a rel link with params already included
    if([Uri]::IsWellFormedUriString($Endpoint, [System.UriKind]::Absolute)) {
        $uri = [UriBuilder]::new($Endpoint)
    } else {
        $uri = [UriBuilder]::new($env:FRESHSERVICE_ROOT)
        $uri.Path = $Endpoint
        $uri.Query = (params_to_query_string $Body).ToString()
    }
    $params = @{
        Method = 'GET'
        Uri = $uri.ToString()
        SkipHttpErrorCheck = $true
        Headers = @{
            Authorization = "Basic ${env:FRESHSERVICE_AUTH}"
            Accept = 'application/json'
        }
    }

    Write-Debug "$($params.Method) $($params.Uri)"
    Invoke-WebRequest @params
}


function fresh_put {
    Param(
        $Endpoint,
        $Body
    )

    $uri = [UriBuilder]::new($env:FRESHSERVICE_ROOT)
    $uri.Path = $Endpoint

    $params = @{
        Method = 'PUT'
        Uri = $uri.ToString()
        SkipHttpErrorCheck = $true
        Body = $Body | ConvertTo-Json -Depth 4
        ContentType = 'application/json'
        Headers = @{
            Authorization = "Basic ${env:FRESHSERVICE_AUTH}"
            Accept = 'application/json'
        }
    }

    Write-Debug "$($params.Method) $($params.Uri) $($params.Body)"
    Invoke-WebRequest @params
}


function fresh_post {
    Param(
        $Endpoint,
        $Body
    )

    $uri = [UriBuilder]::new($env:FRESHSERVICE_ROOT)
    $uri.Path = $Endpoint

    $params = @{
        Method = 'POST'
        Uri = $uri.ToString()
        SkipHttpErrorCheck = $true
        Body = $Body | ConvertTo-Json -Depth 4
        ContentType = 'application/json'
        Headers = @{
            Authorization = "Basic ${env:FRESHSERVICE_AUTH}"
            Accept = 'application/json'
        }
    }

    Write-Debug "$($params.Method) $($params.Uri) $($params.Body)"
    Invoke-WebRequest @params
}









function Invoke-FreshRequest {
    [CmdletBinding()]
    Param(
    [ValidateSet('GET','PUT')]
    [Parameter(Position=0,Mandatory)]
    [String]$Method,

    [ValidateNotNullOrEmpty()]
    [Parameter(Position=1,Mandatory)]
    [String]$Endpoint,

    [Parameter(Position=2)]
    $Body
    )

    $script = switch($Method) {
        'GET'    { ${Function:fresh_get}      }
        'PUT'    { ${Function:fresh_put}      }
        default  { throw 'unsupported method' }
    }

    while($true) {
        $response = & $script -Endpoint $Endpoint -Body $Body
        $headers = $response.headers
        [Nullable[Int]]$rl_total = [string]$headers['X-Ratelimit-Total']
        [Nullable[Int]]$rl_remaining = [string]$headers['X-Ratelimit-Remaining']
        [Nullable[Int]]$rl_currentrequest = [string]$headers['X-Ratelimit-Used-Currentrequest']
        [Int]$rl_retryafter = $headers['Retry-After'] ? [String]$headers['Retry-After'] : -1

        Write-Debug ("TOTAL:{0:d3} REM:{1:d3} CURR:{2:d3}, RETRY:{3:d3}" -f $rl_total,$rl_remaining,$rl_currentrequest,$rl_retryafter)
        
        # can disrupt apps/automations when tokens completely exhausted
        if($null -ne $rl_remaining -and $rl_remaining -le 50) {
            Write-Debug "Less than 50 API tokens remaining, pausing for 10 seconds"
            Start-Sleep -Seconds 20
            continue
        }

        # pause for retry interval + a bit more for safety
        if($rl_retryafter -ne -1) {
            Write-Debug "Ratelimit hit, retrying in $rl_retryafter seconds"
            Start-Sleep -Seconds ($rl_retryafter * 1.05)
            continue
        }

        if($response.StatusCode -notin 200..300) {
            Write-Error -ErrorAction Stop "Request failed with response code $($response.StatusCode)`n$response"
        }

        $response.Content | ConvertFrom-Json -Depth 10

        # pagination/exit
        if($Method -eq 'GET' -and $response.RelationLink['next']) {
            $Endpoint = $Response.RelationLink.next
            continue
        } else {
            break
        }
    }
}
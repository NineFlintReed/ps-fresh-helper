<#
function Get-FreshTicket {
    [CmdletBinding()]
    Param(
        [Alias('user_id','requester_id')]
        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='User')]
        $User,

        [ValidateNotNullOrEmpty()]
        [Parameter(ParameterSetName='Agent')]
        $Agent,

        [ValidateRange("Positive")]
        [Parameter(ParameterSetName='TicketId')]
        $TicketId,


        $WorkspaceId
    )

    $params = @{
        Method = 'GET'
        Endpoint = "/api/v2/tickets"
        Body = @{}
    }

    $is_filter = $false

    switch($PSCmdlet.ParameterSetName) {
        'TicketId' {
            $params.Endpoint += "/$TicketId"
        }
        'User' {
            $params.Endpoint += '/filter'
            $is_filter = $true
            $params.Body['query'] = switch($User) {
                {$_ -as [Int64]}       { '"user_id:{0}"' -f (Get-FreshUser -User $User).id }
                {$_ -as [MailAddress]} { '"user_id:{0}"' -f (user_email_to_id $User)    }
            } 
        }
        'Agent' {
            $params.Endpoint += '/filter'
            $is_filter = $true
            $params.Body['query'] = switch($Agent) {
                {$_ -as [Int64]}       { '"agent_id:{0}"' -f (Get-FreshUser -User $Agent).id }
                {$_ -as [MailAddress]} { '"agent_id:{0}"' -f (user_email_to_id $Agent)    }
            }           
        }
        default {
            throw
        }
    }


    if($PSBoundParameters.ContainsKey('WorkspaceId')) {
        $params.Body['workspace_id'] = $WorkspaceId
    }

    # hurrr durrr just for this endpoint lets using a completely different method of pagination
    if($is_filter) {
        $total = $null
        $accumulated = 0
        $params.Body['page'] = 1
        do {
            $chunk = Invoke-FreshRequest @params
            $total ??= $chunk.total
            $tickets = $chunk.tickets
            $accumulated += $tickets.count
            $params.Body.Page++
            $tickets
        } while($accumulated -le $total)
    } else {
        Invoke-FreshRequest @params | Select-Object -ExpandProperty 'ticket*'
    }
}
#>






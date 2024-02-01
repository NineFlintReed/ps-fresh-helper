
function Add-FreshTicketNote {
    Param(
        [Parameter(Mandatory)]
        [ValidateRange(1,999999)]
        [Uint64]$TicketId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$NoteHTMLContent,

        [Switch]$Public
    )

    $params = @{
        Method = 'POST'
        Endpoint = "/api/v2/tickets/$TicketId/notes"
        Body = @{ body = $NoteHTMLContent }
    }
    if($Public) {
        $params['private'] = $false
    }

    $result = Invoke-FreshRequest @params
    return $result
}
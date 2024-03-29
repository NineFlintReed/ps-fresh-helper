function Add-FreshTask {
    Param(
        [ValidateRange("Positive")]
        [Parameter(Mandatory)]
        [Int]$TicketId,

        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory)]
        [String]$Title,

        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory)]
        [String]$Description,

        [ValidateSet('Open','InProgress','Completed')]
        [String]$Status,
        
        [Alias('group_id')]
        $Group,

        $DueDate
    )

    $params = @{
        Method = 'POST'
        Endpoint = "/api/v2/tickets/$TicketId/tasks"
        Body = @{
            title = $Title
            description = $Description
            status = switch($Status) {
                'Open'       { 1 }
                'InProgress' { 2 }
                'Completed'  { 3 }
                default      { 1 }
            }
            group_id = $Group
        }
    }


    if($DueDate) {
        $params.body['due_date'] = $DueDate
    }
    if($Group) {
        $params.body['group_id'] = $Group
    }

    fresh @params |
    Select-Object -ExpandProperty 'task'
}
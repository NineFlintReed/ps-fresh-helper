function New-FreshTicket {
    Param(
        [ValidateNotNullOrEmpty()]
        [String]$RequesterEmail,

        [ValidateSet('Open','Pending','Resolved','Closed')]
        [String]$Status = 'Open',

        [ValidateSet('Low','Medium','High','Urgent')]
        [String]$Priority = 'Low',

        [Parameter(Mandatory)]
        [ValidateSet('Incident','ServiceRequest')]
        [String]$Type,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Subject,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Description,

        [Parameter(Mandatory)]
        $DueBy,

        $GroupId,

        [String[]]$Tags = @(),

        [HashTable]$CustomFields
    )

    $status_id = switch($Status) {
        'Open'     { 2 }
        'Pending'  { 3 }
        'Resolved' { 4 }
        'Closed'   { 5 }
    }
    $priority_id = switch($Priority) {
        'Low'    { 1 }
        'Medium' { 2 }
        'High'   { 3 }
        'Urgent' { 4 }
    }

    $body = @{
        email = $RequesterEmail
        subject = $Subject
        priority = $priority_id
        status = $status_id
        description = $Description
        due_by = $DueBy -as [DateTime]
        fr_due_by = $DueBy -as [DateTime]
        tags = $Tags
    }
    if($CustomFields) {
        $body['custom_fields'] = $CustomFields
    }
    if($GroupId) {
        $body['group_id'] = $GroupId
    }

    $result = Invoke-FreshRequest -Method POST -Endpoint "/api/v2/tickets" -Body $body -ErrorAction Stop

    if($Type -eq 'ServiceRequest') {
        $null = Invoke-FreshRequest -Method PUT -Endpoint "/api/v2/tickets/$($result.ticket.id)" -Body @{ type = 'Service Request' }
    }

    return $result.ticket
}
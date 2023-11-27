$script:FreshCache = [PSCustomObject]@{
    #Locations = [Collections.Generic.Dictionary[String, Int64]]::new()
    #Departments = [Collections.Generic.Dictionary[String, Int64]]::new()
    #Groups = [Collections.Generic.Dictionary[String, Int64]]::new()
    Requesters = [Collections.Generic.Dictionary[MailAddress, Int64]]::new()
}

$FreshCache |
Add-Member -MemberType ScriptMethod -Name Clear -Value {
    #$this.Locations.Clear()
    #$this.Departments.Clear()
    #$this.Groups.Clear()
    $this.Requesters.Clear()
}

$FreshCache |
Add-Member -MemberType ScriptMethod -Name GetRequesterId -Value {
    Param([Parameter(Mandatory)][MailAddress]$RequesterEmail)
    if($this.Requesters.ContainsKey($RequesterEmail)) {
        return $this.Requesters[$RequesterEmail]
    } else {
        $user_obj = Invoke-FreshRequest -Method 'GET' -Endpoint "/api/v2/requesters" -Body @{
            include_agents='true'
            email = $RequesterEmail
        } | Select-Object -ExpandProperty 'requesters'

        if(-not $user_obj) {
            Write-Error -ErrorAction Stop "Unable to find requester with email '$RequesterEmail'"
        }
        $this.Requesters[$user_obj.primary_email] = $user_obj.id
        return $this.Requesters[$RequesterEmail]
    }
}
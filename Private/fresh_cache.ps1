$global:FreshCache = [PSCustomObject]@{
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

function user_email_to_id {
    Param($email)
    if($FreshCache.Requesters.ContainsKey($email)) {
        $FreshCache.Requesters[$email]
    } else {
        (Get-FreshUser -User $email).id
    }
}
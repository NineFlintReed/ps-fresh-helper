Set-Variable -Name 'FreshCache' -Scope Global -Value ([PSCustomObject]@{
    User = [PSCustomObject]@{
        FromId = @{}
        FromMail = @{}
    }
})

$global:FreshCache | Add-Member -MemberType ScriptMethod -Name 'AddUser' -Value {
    Param($user)
    $this.User.FromId[$user.id] = $user
    $this.User.FromMail[$user.primary_email] = $user
}

$global:FreshCache | Add-Member -MemberType ScriptMethod -Name 'GetUser' -Value {
    Param($user)
    if($user -as [Uint64]) {
        $this.User.FromId[$user]
    } elseif($user -as [MailAddress]) {
        $this.User.FromMail[$user]
    }
}




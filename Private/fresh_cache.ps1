Set-Variable -Name 'FreshCache' -Scope Global -Value ([PSCustomObject]@{
    User = [PSCustomObject]@{
        FromId = @{}
        FromMail = @{}
    }
    AssetType = [PSCustomObject]@{
        FromId = @{}
        FromName = @{}
    }
})


# preloading some parts of the cache for use with autocomplete etc
Invoke-FreshRequest -Method 'GET' -Endpoint "/api/v2/asset_types" |
Select-Object -ExpandProperty 'asset_types' |
ForEach-Object {
    $FreshCache.AssetType.FromId[$_.id] = $_
    $FreshCache.AssetType.FromName[$_.name] = $_
}


# utility methods for retrieving cached properties
$global:FreshCache |
Add-Member -MemberType ScriptMethod -Name 'AddUser' -Value {
    Param($user)
    $this.User.FromId[$user.id] = $user
    $this.User.FromMail[$user.primary_email] = $user
} -PassThru |
Add-Member -MemberType ScriptMethod -Name 'GetUser' -Value {
    Param($user)
    if($user -as [Uint64]) {
        $this.User.FromId[$user]
    } elseif($user -as [MailAddress]) {
        $this.User.FromMail[$user]
    }
} -PassThru |
Add-Member -MemberType ScriptMethod -Name 'GetAssetType' -Value {
    Param($assettype)
    if($assettype -as [Uint64]) {
        $this.AssetType.FromId[$assettype]
    } elseif($user -as [String]) {
        $assettype.AssetType.FromName[$assettype]
    }
}
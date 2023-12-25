Set-Variable -Name 'FreshCache' -Scope Global -Value ([PSCustomObject]@{
    User = [PSCustomObject]@{
        FromId = @{}
        FromMail = @{}
    }
    AssetType = [PSCustomObject]@{
        FromId = @{}
        FromName = @{}
    }
    Workspace = [PSCustomObject]@{
        FromId = @{}
        FromName = @{}
    }
})


# utility methods for retrieving cached properties

$global:FreshCache |
Add-Member -MemberType ScriptMethod -Name 'AddUser' -Value {
    Param($user)
    $this.User.FromId[$user.id.ToString()] = $user
    $this.User.FromMail[$user.primary_email] = $user
}

$global:FreshCache |
Add-Member -MemberType ScriptMethod -Name 'GetUser' -Value {
    Param([String]$user)
    if($user -as [Uint64]) {
        $this.User.FromId[$user]
    } elseif($user -as [MailAddress]) {
        $this.User.FromMail[$user]
    }
}

$global:FreshCache |
Add-Member -MemberType ScriptMethod -Name 'GetAssetType' -Value {
    Param([String]$assettype)
    if($assettype -as [Uint64]) {
        $this.AssetType.FromId[$assettype]
    } elseif($assettype -as [String]) {
        $this.AssetType.FromName[$assettype]
    }
}

$global:FreshCache |
Add-Member -MemberType ScriptMethod -Name 'GetWorkspace' -Value {
    Param([String]$workspace)
    if($workspace -as [Uint64]) {
        $this.Workspace.FromId[$workspace]
    } elseif($workspace -as [String]) {
        $this.Workspace.FromName[$workspace]
    }
}


# preloading some parts of the cache for use with autocomplete etc
function Initialize-FreshCache {
    Invoke-FreshRequest -Method 'GET' -Endpoint "/api/v2/asset_types" |
    Select-Object -ExpandProperty 'asset_types' |
    ForEach-Object {
        $FreshCache.AssetType.FromId[$_.id.ToString()] = $_
        $FreshCache.AssetType.FromName[$_.name.ToString()] = $_
    }
    
    Invoke-FreshRequest -Method 'GET' -Endpoint "/api/v2/workspaces" |
    Select-Object -ExpandProperty 'workspaces' |
    ForEach-Object {
        $FreshCache.Workspace.FromId[$_.id.ToString()] = $_
        $FreshCache.Workspace.FromName[$_.name.ToString()] = $_
    }
}
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
    Product = [PSCustomObject]@{
        FromId = @{}
        FromName = @{}
    }
})


# utility methods for retrieving cached properties

function add_user_cached {
    Param($userobj)
    $FreshCache.User.FromId[$userobj.id.ToString()] = $userobj
    $FreshCache.User.FromMail[$userobj.primary_email] = $userobj
}

function get_user_cached {
    Param([String]$key = '')
    if([regex]::Match($key,'^\d+$').Success) {
        $FreshCache.User.FromId[$key]
    } elseif([mailaddress]::TryCreate($key, [ref]$null)) {
        $FreshCache.User.FromMail[$key]
    } else {
        throw "Key '$key' must either be a positive integer or email address"
    }
}

function get_workspace_cached {
    Param([String]$key = '')
    if([regex]::Match($key,'^\d+$').Success) {
        $FreshCache.Workspace.FromId[$key]
    } else {
        $FreshCache.Workspace.FromName[$key]
    }
}

function get_assettype_cached {
    Param([String]$key = '')
    if([regex]::Match($key,'^\d+$').Success) {
        $FreshCache.AssetType.FromId[$key]
    } else {
        $FreshCache.AssetType.FromName[$key]
    }
}

function get_product_cached {
    Param([String]$key = '')
    if([regex]::Match($key,'^\d+$').Success) {
        $FreshCache.Product.FromId[$key]
    } else {
        $FreshCache.Product.FromName[$key]
    }
}

# preloading some parts of the cache for use with autocompletion and the ability
# to specify a name/other identifier in place of a numeric ID
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

    Invoke-FreshRequest -Method 'GET' -Endpoint "/api/v2/products" |
    Select-Object -ExpandProperty 'products' |
    ForEach-Object {
        $FreshCache.Product.FromId[$_.id.ToString()] = $_
        $FreshCache.Product.FromName[$_.name] = $_
    }

}
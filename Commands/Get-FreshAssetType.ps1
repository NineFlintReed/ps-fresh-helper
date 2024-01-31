# from preloaded cache, very unlikely it will change during a session
function Get-FreshAssetType {
    [CmdletBinding(DefaultParameterSetName='All')]
    Param(
        [Parameter(ParameterSetName='Single')]
        [ValidateNotNullOrEmpty()]
        $AssetType,

        [Switch]$IncludeHidden
    )

    switch($PSCmdlet.ParameterSetName) {
        'Single' {
            $result = get_assettype_cached "$AssetType"
            if(-not $result) {
                Write-Error "Asset type '$AssetType' not found" -ErrorAction Stop -Category ObjectNotFound
            } else {
                $result
            }
        }
        'All' {
            if($IncludeHidden) {
                $FreshCache.AssetType.FromId.Values
            } else {
                $FreshCache.AssetType.FromId.Values.Where({$_.visible})
            }
        }
    }
}
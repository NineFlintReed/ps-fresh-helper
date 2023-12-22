# from preloaded cache, very unlikely it will change during a session
function Get-FreshAssetType {
    [CmdletBinding(DefaultParameterSetName='All')]
    Param(
        [Parameter(ParameterSetName='Single')]
        [ValidateNotNullOrEmpty()]
        $AssetType
    )

    switch($PSCmdlet.ParameterSetName) {
        'Single' {
            $result = $FreshCache.GetAssetType($AssetType)
            if(-not $result) {
                Write-Error "Asset type '$AssetType' not found" -ErrorAction Stop -Category ObjectNotFound
            } else {
                $result
            }
        }
        'All' {
            $FreshCache.AssetType.FromId.Values
        }
    }
}
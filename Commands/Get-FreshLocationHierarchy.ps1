function Get-FreshLocationHierarchy {
    [CmdletBinding()]
    Param(
        [Alias('location_id')]
        [ValidateRange("Positive")]
        [Parameter(ValueFromPipelineByPropertyName)]
        [Int64]$LocationId
    )
    process {
        # full listing
        $locations = Get-FreshLocation
        
        # cursed recursion
        function build_tree {
            Param($NodeId)
            $node = $locations | Where-Object { $_.id -eq $NodeId }
            if ($null -ne $node) {
                $children = $locations | Where-Object { $_.parent_location_id -eq $NodeId }
                $node |
                Add-Member -MemberType NoteProperty -Name "Children" -Value ($children | ForEach-Object { build_tree $_.id })
            }
            return $node
        }
        
        # container object
        $result = [pscustomobject]@{RootLocation = @()}
        
        # if no root location specified, get all
        if(-not $LocationId) {
            $Locations |
            Where-Object { $null -eq $_.parent_location_id } |
            ForEach-Object {
                $result.RootLocation += build_tree $_.id 
            }
        } else {
            $result.RootLocation = build_tree $LocationId
        }

        $result
    }
}
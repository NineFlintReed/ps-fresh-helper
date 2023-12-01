#function Get-FreshLocationHierarchy {
#    [CmdletBinding()]
#    Param(
#        [Alias('location_id')]
#        [ValidateRange("Positive")]
#        [Parameter(ValueFromPipelineByPropertyName)]
#        [Int64]$LocationId
#    )
#    process {
#        # full listing
#        $locations = Get-FreshLocation
#        
#        # cursed recursion
#        function build_tree {
#            Param($node_id)
#            $node = $locations | Where-Object { $_.id -eq $node_id }
#            if ($null -ne $node) {
#                $children = $locations | Where-Object { $_.parent_location_id -eq $node_id }
#                $node |
#                Add-Member -MemberType NoteProperty -Name "Children" -Value ($children | ForEach-Object { build_tree $_.id })
#            }
#            return $node
#        }
#                
#        # if no root location specified, get all
#        if(-not $LocationId) {
#            $Locations |
#            Where-Object { $null -eq $_.parent_location_id } |
#            ForEach-Object {
#                build_tree $_.id 
#            }
#        } else {
#            build_tree $LocationId
#        }
#
#    }
#}
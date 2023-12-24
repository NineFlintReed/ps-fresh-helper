# from preloaded cache, very unlikely it will change during a session
function Get-FreshWorkspace {
    [CmdletBinding(DefaultParameterSetName='All')]
    Param(
        [Parameter(Position=0,ParameterSetName='Single')]
        [ValidateNotNullOrEmpty()]
        $Workspace
    )

    switch($PSCmdlet.ParameterSetName) {
        'Single' {
            $result = $FreshCache.GetWorkspace("$Workspace")
            if(-not $result) {
                Write-Error "Workspace '$Workspace' not found" -ErrorAction Stop -Category ObjectNotFound
            } else {
                $result
            }
        }
        'All' {
            $FreshCache.Workspace.FromId.Values
        }
    }
}
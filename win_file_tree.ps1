<#
    .SYNOPSIS
    Display catalog tree of given path
    .DESCRIPTION
    Display catalog tree of given path with indentation. User can decide whether to display files.
    .EXAMPLE 
    .\win_file_tree.ps1 -Parent "C:\Users\Marek Grudkowski\Desktop" -DisplayingFiles 1
    .EXAMPLE
    .\win_file_tree.ps1 -Parent "C:\Users\Marek Grudkowski\Desktop"
    .NOTES
    Author: Marek Grudkowski
    .LINK
    https://github.com/GeoMarek/Shell-scripts
#>



[CmdletBinding()]
param
(
    # path to displaying 
    [Parameter(mandatory=$true)]
    [string]
    $Parent
    ,
    # flag whether to display files
    [Parameter()]
    [bool]
    $DisplayingFiles = 0
)


# recursive function get into file system tree
function Get-DirectoryTree
{
    param
    (
        # path to object which will be checked
        [Parameter(mandatory=$true)]
        [string]
        $Path
        ,
        # actual depth from root
        [Parameter(mandatory=$true)]
        [int]
        $Depth
    )

    # get all items from $Path
    $items = Get-ChildItem $Path
    
    # loop throuh all items
    foreach($item in $items)
    {
        if ($item.Mode.contains('d'))
        {
            # write file to console
            Write-File -Path $item -Depth $Depth -isDirectory 1
            # increment depth of file tree
            $item_depth = 1 + $Depth
            # recursive call
            Get-DirectoryTree -Path $item.FullName -Depth $item_depth
        }
        else
        {
            # write file to console
            Write-File -Path $item -Depth $Depth -isDirectory 0
        }
    }
}


# function to write a file
function Write-File
{
    param
    (
        # file name
        [Parameter(mandatory=$true)]
        [string]
        $Path
        ,
        # actual depth from root
        [Parameter(mandatory=$true)]
        [int]
        $Depth
        ,
        # flag if file is directory
        [Parameter(mandatory=$true)]
        [bool]
        $isDirectory

    )
    
    # check for displaying directories
    if ($DisplayingFiles -eq $true -and $isDirectory -eq 0)
    {
        # display file in yellow
        Write-Host "$("    "*$Depth)└── $item" -ForegroundColor DarkYellow
    }
    elseif ($isDirectory -eq 1)
    {
        # display directory in red
        Write-Host "$("    "*$Depth)DIR├── $item" -ForegroundColor Red
    }
     
} 


# main call of function
Get-DirectoryTree $Parent -Depth 1

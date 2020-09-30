function Get-DirectoryTree
{
    param
    (
        [Parameter(mandatory=$true)][string]$Path
        #[Parameter(mandatory=$true)][int]$Depth
    )

    # get all items from $Path
    $items = Get-ChildItem $Path
    
    
    foreach($item in $items)
    {
        if ($item.Mode.contains('d'))
        {
            "directory"; $item.FullName
        }
        else
        {
            "File"; $item.FullName
        }
    }

    
    
    
    
    
    
    # test main item
    if (Test-Path -Path $Path -PathType Container) 
    {
        "directory"
    }
    else 
    {
            
        "file"
    }

}


Get-DirectoryTree -Path $args[0] 

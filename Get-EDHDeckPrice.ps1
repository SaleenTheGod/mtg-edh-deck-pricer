[cmdletbinding()]
Param(
    [parameter(Mandatory = $true,ValueFromPipeline=$True)] [string]$Decklist,
    # [ValidateRange(1, 20)] [int]$ConcurrentTasks = 1,
    [ValidateRange(50,100)] [string]$APIWaitTime = 100,
    [ValidateSet("SilentlyContinue","Continue")] [string]$DebugPreference = "Continue"
)
BEGIN
{
    $scryfallHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $scryfallHeaders.Add("Cookie", "__cfduid=da5a6eb9a6305f9709d65b5b29d6672101615999064")
    $scryfallResponseArray = @()
    $mtgCardArray = @()
    
}
PROCESS 
{
    Foreach ($cardName in Get-Content $Decklist)
    {
        $scryfallResponse = Invoke-RestMethod "https://api.scryfall.com/cards/named?fuzzy=$cardName" -Method 'GET' -Headers $scryfallHeaders
        $scryfallResponse | ConvertTo-Json
        $scryfallResponseArray += $scryfallResponse

        # According to their documentaion, Scryfall asks that we wait anywhere between 50-100 Seconds between API calls. In order to be a good citizen I have baked it into this script.
        # More info avalible here: https://scryfall.com/docs/api#rate-limits-and-good-citizenship

        Start-Sleep -Milliseconds $APIWaitTime
    }

    Clear-Host

    Foreach ($mtgCard in $scryfallResponseArray)
    {   
        
        $mtgCardObject = [PSCustomObject]@{
            Name        = $mtgCard.name
            "USD Price"      = $mtgCard.prices.usd
            "USD Price Foil"      = $mtgCard.prices.usd_foil
        }
        $mtgCardArray += $mtgCardObject
    }

    $mtgCardArray | Export-Csv -Path $Decklist".csv" -NoTypeInformation
}
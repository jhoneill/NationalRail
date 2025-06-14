if (Test-Path ("$env:USERPROFILE\natrail.xml"))  { $natRailCred  = Import-Clixml "$env:USERPROFILE\natrail.xml"  }
else {
        throw "Could not find $env:USERPROFILE\natrail.xml; get a key at https://realtime.nationalrail.co.uk/OpenLDBWSRegistration and " + [System.Environment]::NewLine +
              "save it with Get-Credential -user 'token' -message 'Paste Nationalrail key' | Export-Clixml  $env:USERPROFILE\natrail.xml "
}

function Export-StationList  {
    <#
    .Synopsis
        Exports a CSV of stations: the others use the 3 letter crs code this is just a quick way to discover the codes
    #>
    param (
        $CsvPath = "$env:USERPROFILE\NationalRailStations.csv"
    )
    "a".."z" | ForEach-Object { (
                    Invoke-restmethod -Uri "https://stationpicker.nationalrail.co.uk/stationPicker/$_" -Headers @{ "origin"="https://www.nationalrail.co.uk" }
                ).payload.stations
             }  | Sort-Object Name, crsCode | Export-Csv -Path $CsvPath -NoTypeInformation
    Get-item $CsvPath
}

function Invoke-NationalRail {
    param (
        [string]$Method = 'Get',
        [string]$Url,
        [hashtable]$Params
    )
    $irmParams = @{Method = $Method; Uri = "https://lite.realtime.nationalrail.co.uk/OpenLDBWS/api/20220120$Url"; Body = $Params }
    if ($PSVersionTable.PSVersion.Major -gt 5) {
                      $irmParams += @{Authentication = 'Basic'; Credential = $natRailCred}
    }
    else             {$irmParams += @{Headers= @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($natRailCred.UserName + ':' + $natRailCred.GetNetworkCredential().Password))}}}

    Invoke-RestMethod @irmParams
}

function Get-RailService     {
    <#
      .SYNOPSIS
        Take a service ID retured by one of the other functions and gets its details.
    #>
    param(
        [parameter(Mandatory = $true)]
        [string]$ServiceId
    )
    Invoke-NationalRail -Url "/GetServiceDetails/$serviceId" |  #subsequentCallingPoints.callingpoint .previousCallingPoints.callingpoint
        ForEach-Object {
            if ($_.subsequentCallingPoints ) {$d = $_.subsequentCallingPoints.callingpoint[-1]} else {$d=[pscustomobject]@{locationName=$_.LocationName} }
            if ($_.previousCallingPoints   ) {$o = $_.previousCallingPoints.callingpoint[-0]}   else {$o=[pscustomobject]@{locationName=$_.LocationName} }
            Add-Member -InputObject $_ -NotePropertyName destination -NotePropertyValue $d
            Add-Member -InputObject $_ -NotePropertyName origin      -NotePropertyValue $o
            Add-Member -InputObject $_ -Name             generatedTime           -Value "generatedAt"  -MemberType AliasProperty
            Add-Member -InputObject $_ -Name             generatedlocation       -Value "locationName" -MemberType AliasProperty
            Add-Member -InputObject $_ -TypeName "NationalRailService" -PassThru
        }
}

function Get-StationBoard    {
    <#
      .SYNOPSIS
        Returns all public departures and/or arrivals for the supplied CRS code within a defined time window.
    #>
    [Alias("Get-RailArrivals","Get-RailDepartures")]
    param (
        #The CRS code of the station whose board is being request.
        [parameter(Mandatory = $true)]
        [string]$StationCode,
         #The number of services to return in the resulting station board.
        [Alias("NumRows")]
        [int]$Rows    = 10,
        #An offset in minutes against the current time to provide the station board for.
        [Alias('TimeOffset')]
        [int]$OffsetMinutes = 0,
        #How far into the future in minutes, relative to the offset, to return services for.
        [Alias('TimeWindow')]
        [int]$WindowMinutes = 120,
        [Switch]$NoDetails
    )

    if     ( $NoDetails  -and $MyInvocation.InvocationName -eq "Get-RailArrivals"   ) {$url = "/GetArrivalBoard/"           + $StationCode.ToUpper()}
    elseif (                  $MyInvocation.InvocationName -eq "Get-RailArrivals"   ) {$url = "/GetArrBoardWithDetails/"    + $StationCode.ToUpper()}
    elseif ( $NoDetails  -and $MyInvocation.InvocationName -eq "Get-RailDepartures" ) {$url = "/GetDepartureBoard/"         + $StationCode.ToUpper()}
    elseif (                  $MyInvocation.InvocationName -eq "Get-RailDepartures" ) {$url = "/GetDepBoardWithDetails/"    + $StationCode.ToUpper()}
    elseif ( $NoDetails )                                                             {$url = "/GetArrivalDepartureBoard/"  + $StationCode.ToUpper()}
    else                                                                              {$url = "/GetArrDepBoardWithDetails/" + $StationCode.ToUpper()}
    $response = Invoke-NationalRail -Url $url -Params  @{numRows = $Rows; timeOffset = $OffsetMinutes; timeWindow  = $WindowMinutes}
    if ($response.nrccMessages.value) {
        $response.nrccMessages| foreach-object {
            $v = $_.value   -replace "</?p>","" -replace "[\r\n]+" , ""
            if ($v -match   '<a\s+href=\s*"([^"]+)">([^<]+)</a>'  ) {
                  Write-host ($v -replace '<a\s+href=\s*"([^"]+)">([^<]+)</a>' , ($psStyle.FormatHyperlink($Matches[2],$Matches[1])))
            }
            else {Write-host  $v}
        }
    }
    if (-not $response.busServices)   {$result = $response.trainServices}
    elseif  ($response.trainServices) {$result = $response.trainServices + $response.busServices |   # if scheduled time of arrival/departure is the other side of midnight sort as tomorrow...
                                         Sort-Object -Property  @{e={if ($response.generatedAt.Hour -gt 20 -and ($_.std -like "0*" -or $_.sta -like "0*")) {$response.generatedAt.AddDays(1)} else  {$response.generatedAt}}},
                                                                @{e={if ($_.std) {$_.std} else {$_.sta} }} }
    else                              {$result = $response.busServices}
    if (-not $result) { Write-Warning "No Matching trains" ; return }
    $result |
        Add-Member -PassThru -NotePropertyName generatedTime     -NotePropertyValue $response.generatedAt |
        Add-Member -PassThru -NotePropertyName generatedlocation -NotePropertyValue $response.locationName |
        Add-Member -PassThru -TypeName "NationalRailService"
}

function Get-NextDeparture   {
    <#
    .SYNOPSIS
          Returns the next public departure for the supplied CRS code within a defined time window to the locations specified in the filter.
    #>
    [ALias('Get-FastestDeparture')]
    param (
        #The CRS code of the location for which the request is being made.
        [parameter(Mandatory = $true)]
        [Alias('DepartingFrom')]
        [string]$StationCode,
        #A list of CRS codes of the destinations location to filter, at least 1 but not greater than 15 must be supplied.
        [string]$FilterList,
         #The number of services to return in the resulting station board.
        [int]$Rows    = 10,
        #An offset in minutes against the current time to provide the station board for.
        [int]$OffsetMinutes = 0,
        #How far into the future in minutes, relative to TimeOffset, to return services for.
        [int]$WindowMinutes = 120,
        [Switch]$NoDetails,
        [Switch]$Fastest
    )
    if     ( $NoDetails  -and ($Fastest -or $MyInvocation.InvocationName -eq "Get-FastestDeparture"  )) {$url = "/GetFastestDepartures/"               + $StationCode.ToUpper() + "/" + $FilterList.ToUpper()}
    elseif (                   $Fastest -or $MyInvocation.InvocationName -eq "Get-FastestDeparture"   ) {$url = "/GetFastestDeparturesWithDetails/"    + $StationCode.ToUpper() + "/" + $FilterList.ToUpper()}
    elseif ( $NoDetails )                                                                               {$url = "/GetNexttDepartures/"                 + $StationCode.ToUpper() + "/" + $FilterList.ToUpper()}
    else                                                                                                {$url = "/GetFastestDeparturesWithDetails/"    + $StationCode.ToUpper() + "/" + $FilterList.ToUpper()}
    $response = Invoke-NationalRail -Url $url  -Params  @{numRows = $Rows; timeOffset = $OffsetMinutes; timeWindow  = $WindowMinutes}
    if (-not $response.departures.service) {Write-Warning "No Matching trains" ; return}
    $response.departures.service |
        Add-Member -PassThru -NotePropertyName generatedTime     -NotePropertyValue $response.generatedAt  |
        Add-Member -PassThru -NotePropertyName generatedlocation -NotePropertyValue $response.locationName |
        Add-Member -PassThru -TypeName "NationalRailService"
}

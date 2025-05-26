# National rail

![Powered by National Rail Enquiries"](NRE_Powered_logo.jpg)

## Usage

[Register for use with the National Rail site](http://realtime.nationalrail.co.uk/OpenLDBWSRegistration). National Rail will email you a token. Copy this and run    
`Get-Credential -user 'token' -messsage 'Paste National Rail key' | Export-Clixml  '$env:USERPROFILE\natrail.xml' `

Keep the key safe because if you use a different computer or a different user account you will need to re-create the XML file.    
Connections to the service logon using basic authentication with "token" as the user name. 

You can then import the module.

**There are seven commands**: five of them get departures and arrivals these use a **3 letter code for the station**. 
If you don't know the station codes you need, you can download a list with `Export-StationList` or discover them on National Rail's web site.

## Boards
`Get-StationBoard PAD` will get 10 rows of detailed arrivals and departures for Paddington. 
You can request fewer rows with the `Rows` parameter, but National Rail's service sends a maximum of 10 *detailed* rows.
```
    Station: London Paddington

Platform   Service                      Expected   Details
--------   -------                      --------   -------
5          19:09 Arrival from Swansea   19:16      (Service from Swansea)
6          19:10 To Heathrow Airport T5 On time    Calling at: Heathrow Airport T123, Heathrow Airport T5.
A          19:11 To Abbey Wood          On time    Calling at: Bond Street, Tottenham Court Road, Farringdon,
                                                   London Liverpool Street, Whitechapel, Canary Wharf (Elizabeth       
                                                   line), Custom House, Woolwich (Elizabeth line), Abbey Wood.
                                                   (Service from Maidenhead)
2          19:13 To Swindon             On time    Calling at: Reading, Didcot Parkway, Swindon.
...
```
**Arrival from** means the train *terminates* here. If there is no **Service from** in the details, that means the train *starts* here.

`Get-StationBoard PAD -NoDetails`  will get 10 rows of arrivals and departures for Paddington *without* details, and the 10-row limit no longer applies.    

`Get-RailArrivals` and `Get-RailDepartures` are aliases for `Get-StationBoard`; when they are used, the command requests only arrivals or only departures. 

All three forms take parameters `-OffSetMinutes` and `-WindowMinutes` e.g. `-OffSetMinutes 60  -WindowMinutes 15` requests trains expected in 60-75 minutes.     
Even if you request 1000 rows and a 1000 minute window, the service seems to be limited to a maximum of two hours.
  
`Get-RailDepartures Pad -no -ro 30` will display 30 rows for departures, without details, which means no stops are listed and the service ID appears instead.
```
> Get-RailDepartures PAD -NoDetails -rows 5

    Station: London Paddington

Platform   Service                      Expected   Details
--------   -------                      --------   -------
           19:13 To Swindon             On time    serviceID: 658067PADTON__
A          19:15 To Gidea Park          On time    serviceID: 665422PADTLL__
B          19:17 To Reading             On time    (Service from Abbey Wood) serviceID: 650956PADTLL__
A          19:19 To Abbey Wood          On time    (Service from Heathrow Airport T4) serviceID: 650562PADTLL__
9          19:20 To Oxford              On time    serviceID: 658197PADTON__
```
## Services

To find out detals of a service from a short board you can use:     
```
> Get-RailService 658067PADTON__

    Station: London Paddington

Platform   Service                      Expected   Details
--------   -------                      --------   -------
           19:13 To Swindon                        Calling at: Reading, Didcot Parkway, Swindon.
```

## Next Train to...

`Get-NextDeparture PAD RDG` gets the train leaving Paddington bound for Reading which *departs* first.         
This has an altenate 
`Get-FastestDeparture PAD RDG`  gets the train leaving Paddington bound for Reading which *arrives* first.

Both accept the `-OffsetMinutes` parameter (`-Rows` is accepted but ignored). Multiple destinations can be written as `'RDG,SWI'`

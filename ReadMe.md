# nationalrail

![Powered by National Rail Enquiries"](NRE_Powered_logo.jpg)

## Usage

[Register for use with the National Rail site](http://realtime.nationalrail.co.uk/OpenLDBWSRegistration). National Rail will email you a token  Copy this and run    
`Get-Credential -user 'token' -messsage 'Paste National Rail key' | Export-Clixml  '$env:USERPROFILE\natrail.xml' `

Keep the key safe because if you use a different computer or a different user you will to re-create the XML file.    
Connections to the service logon using basic authentication with "token" as the user name. 

You can then import the module

There are seven commands five of them get Departures and arrivals these use a 3 letter code for the station. 
If you don't know the station codes you need you can download a list with `Export-StationList` or discover them on national rail's web site

`Get-StationBoard PAD` Will get 10 rows of detailed arrivals and departures for Paddington        you can request 1-10 rows with the `rows` parameter    
`Get-StationBoard PAD -NoDetails`  Will get 10 rows  arrivals and departures for Paddington without details and  you can request more than 10 rows with the `rows` parameter    
`Get-StationBoard` takes `-OffSetMinutes` and `-WindowMinutes` parameters e.g. `-OffSetMinutes 60  -WindowMinutes 15` returns trains expected in 60-75 minutes.     
Note the data only goes a certain distance into the future. 

`Get-RailArrivals` and `Get-RailDepartures` are aliases for `Get-StationBoard`; when they are used the command gets only arrivals or only departures
  
`Get-RailDepartures Pad -no -ro 30` will display 30 rows for departures. No details are shown but the service ID is listed, to find out detals you can use     
`Get-RailService  1234PADTON__ `     

`Get-NextDeparture PAD RDG` gets the train leaving Paddington bound for Reading which *departs* first         
This has an altenate 
`Get-FastestDeparture PAD RDG`  gets the train leaving Paddington bound for Reading which *arrives* first     
Both accept the -offsetminutes parameter (rows is accepted but ignored) Multiple destinations can be written as 'RDG,SWI'

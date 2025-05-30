@{
    Author                  =   "James O'Neill"
    CompanyName             =   "Mobula Consulting"
    Copyright               =   "© James O'Neill 2025."
    Description             =   "Module to get National Rail departure and arrival information"
    ModuleVersion           =   "0.0.1"
    PowerShellVersion       =   "5.0"
    GUID                    =   "1ff427aa-8a37-45a5-a443-ec6cc5e48bdc"
    RootModule              =   "NationalRail.psm1"
    FormatsToProcess        = @("NationalRail.format.ps1xml")
    TypesToProcess          = @( )
    RequiredAssemblies      = @( )
    CmdletsToExport         = @( )
    FunctionsToExport       = @("Get-NextDeparture",    "Get-StationBoard", "Get-RailService", "Export-StationList")
    AliasesToExport         = @("Get-FastestDeparture", "Get-RailArrivals", "Get-RailDepartures" )
    FileList                = @("NationalRail.format.ps1xml", "NationalRail.psm1", "NationalRail.psd1")
    PrivateData     = @{
        PSData          = @{ # PSData is module packaging and gallery metadata
            # The primary categorization of this module (from the TechNet Gallery tech tree).
            Category        = " "

            # Keyword tags to help users find this module via navigations and search.
            Tags            =   @()

           # The web address of an icon which can be used in galleries to represent this module
           #IconUri         = "http://pesterbdd.com/images/Pester.png"

            # The web address of this module's project or support homepage.
            ProjectUri      = "https://github.com/jhoneill"

            # The web address of this module's license. Points to a page that's embeddable and linkable.
            LicenseUri      = "https://github.com/jhoneill/NationalRail/blob/main/LICENSE"

            # Indicates this is a pre-release/testing version of the module.
            IsPrerelease    = "False"

           # Release notes for this particular version of the module
           #ReleaseNotes   = $True

           # If true, the LicenseUrl points to an end-user license (not just a source license) which requires the user agreement before use.
           # RequireLicenseAcceptance = ""
        }
    }
    # PowerShellHostName    = ''
    # PowerShellHostVersion = ''
    # DotNetFrameworkVersion= ''
    # CLRVersion            = ''
    # ProcessorArchitecture = ''
    # HelpInfoURI           = ''
    # DefaultCommandPrefix  = ''
    # VariablesToExport     = ''
    # RequiredModules       = @()
    # ScriptsToProcess      = @()
    # NestedModules         = @()
    # ModuleList            = @()
    # ModuleToProcess       = @()
}

@{
    RootModule        = "FailGuru.psm1"
    ModuleVersion     = "1.0.0.0"
    GUID              = "b39020b2-61e6-4e29-a2f2-111f062eb18d"
    Author            = "Anders Laub"
    Copyright         = "(c) 2022 Anders Laub"
    Description       = "Brings a Guru Meditation style screen-of-death to a terminal near you. Ideal for unrecoverable errors in terminal scripts."
    PowerShellVersion = "5.0"
    FunctionsToExport = @(
        "Invoke-GuruMeditation"
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @("callguru")
    PrivateData       = @{
        PSData = @{
            Tags         = @("software", "failure", "guru", "meditation", "terminal", "error", "amiga", "crash" )

            LicenseUri   = "https://github.com/FailGuru/powershell/blob/main/LICENSE"
            ProjectUri   = "https://github.com/FailGuru/powershell"
            ReleaseNotes = "https://github.com/FailGuru/powershell/CHANGELOG.md"
            # Prerelease   = "alpha"
        }
    }
}
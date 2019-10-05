<#
    $env:PSGalleryKey is set in the Continous Integration plaform
    $env:modulePath is set in the build.ps1
    $env:moduleName is set in the build.ps1
    $ENV:BH* are set by the BuildHelpers module
#>
if(
    $env:modulePath -and
    $env:buildOutputPath -and
    $env:BHBuildSystem -ne 'Unknown' -and
    $env:BHBranchName -eq "master" -and
    $env:BHCommitMessage -match '!deploy'
)
{
    Deploy -Name Module {
        By -DeploymentType PSGalleryModule {
            FromSource -Source (Join-Path -path $env:buildOutputPath -ChildPath $env:moduleName)
            To -Targets PSGallery
            WithOptions -Options @{
                ApiKey = $env:PSGalleryKey
            }
        }
    }
}
else
{
    "Skipping deployment: To deploy, ensure that...`n" +
    "`t* You are in a known build system (Current: $ENV:BHBuildSystem)`n" +
    "`t* You are committing to the master branch (Current: $ENV:BHBranchName) `n" +
    "`t* buildoutputpath (Current: $env:buildOutputPath) `n" +
    "`t* modulepath (Current: $env:modulePath) `n" +
    "`t* modulename (Current: $env:modulename) `n" +
    "`t* Your commit message includes !deploy (Current: $ENV:BHCommitMessage)" |
        Write-Host
}
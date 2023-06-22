param (
	[Parameter(Mandatory=$true, HelpMessage = "Provide the Sitename of the Rendering host")]
	[ValidatePattern('^[A-Za-z.]+$')]
	[string]$SiteName,
	
	[Parameter(HelpMessage = "Provide Rendering Host Solution name - if empty, value = {PlatformName}.Rendering")]
	[ValidatePattern('^[A-Za-z.]*$')]
	[string]$RenderingSolutionName = ''
)

Add-RenderingHost-ExampleSite -SiteName $SiteName -RenderingSolutionName $RenderingSolutionName
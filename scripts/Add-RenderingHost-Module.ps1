param (
	[Parameter(Mandatory=$true)]
	[ValidatePattern('^[A-Za-z.]+$')]
	[string]$Name,
   
	[Parameter(Mandatory=$true)]
	[ValidateNotNullOrEmpty()]
	[ValidateSet("Feature","Foundation","Project")]
	[string]$Layer = "Feature",

	[Parameter(Mandatory=$true)]
	[ValidatePattern('^[A-Za-z.]+$')]
	[string]$SiteName,

	[Parameter(HelpMessage = "Provide Rendering Host Solution name - if empty, value = {PlatformName}.Rendering")]
	[ValidatePattern('^[A-Za-z.]*$')]
	[string]$RenderingSolutionName = ''
)

Add-RenderingHost-Module -Name $Name -Layer $Layer -SiteName $SiteName -RenderingSolutionName $RenderingSolutionName
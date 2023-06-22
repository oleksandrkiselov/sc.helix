param (
	[Parameter(Mandatory=$true)]
	[ValidatePattern('^[A-Za-z.]+$')]
	[string]$SiteName,

	[Parameter(HelpMessage = "Provide Rendering Host Solution name - if empty, value = {PlatformName}.Rendering")]
	[ValidatePattern('^[A-Za-z.]*$')]
	[string]$RenderingSolutionName = '',
	
	[Parameter(HelpMessage = "Layout Service path - default value = /sitecore/api/layout/render/jss")]
	[string]$LayoutServicePath = '/sitecore/api/layout/render/jss'
)

Add-RenderingHost-Site -SiteName $SiteName -RenderingSolutionName $RenderingSolutionName -LayoutServicePath $LayoutServicePath
param (
	[Parameter(Mandatory=$true, HelpMessage = "Provide a Sitename for Rendering Host")]
	[ValidatePattern('^[A-Za-z.]+$')]
	[string]$SiteName,
	
	[Parameter(HelpMessage = "Layout Service path - default value = /sitecore/api/layout/render/jss")]
	[string]$LayoutServicePath = '/sitecore/api/layout/render/jss',
	
	[Parameter(HelpMessage = "Provide Rendering Host Solution name - default value = {PlatformName}.Rendering")]
	[ValidatePattern('^[A-Za-z.]*$')]
	[string]$RenderingSolutionName = ''
)

Add-RenderingHost-Solution -SiteName $SiteName -LayoutServicePath $LayoutServicePath -RenderingSolutionName $RenderingSolutionName
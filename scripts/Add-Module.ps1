param (
	[Parameter(Mandatory=$true)]
	[ValidatePattern('^[A-Za-z.]+$')]
	[string]$Name,
	   
	[Parameter(Mandatory=$true)]
	[ValidateNotNullOrEmpty()]
	[ValidateSet("Feature","Foundation","Project")]
	[string]$Layer = "Feature"
)

Add-Module -Name $Name -Layer $Layer
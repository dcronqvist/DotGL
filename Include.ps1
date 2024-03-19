# This script automatically downloads the latest version of this binding and includes it in your .csproj file.
# Can be run from the root of the solution or from the directory of the .csproj file.
# // from the package manager console from Visual Studio or from any PowerShell terminal.

$ProjRoot = Get-Location;

# If .sln file exists, we need to go into the directory of the .sln file.
if (Test-Path -Path "*.sln") {
  $SLNFileName = Get-ChildItem -Filter "*.sln" | Select-Object -First 1;
  $ProjRoot = $ProjRoot.Path + "\" + $SLNFileName.Name.Replace(".sln", "");
}

$DotGLFileURL = "https://raw.githubusercontent.com/dcronqvist/DotGL/master/GL.cs";
$DotGLFilePath = "$ProjRoot\GL.cs";
$CSProjFilePath = Get-ChildItem -Filter "*.csproj" -Path $ProjRoot | Select-Object -First 1;
Write-Host "Found .csproj file: $ProjRoot\$CSProjFilePath";
$CSProjFile = [xml](Get-Content -Path "$ProjRoot\$CSProjFilePath");

$DotGLFile = Invoke-WebRequest -Uri $DotGLFileURL -UseBasicParsing;
$DotGLFileContent = $DotGLFile.Content;

$DotGLFileContent | Out-File -FilePath $DotGLFilePath;
Write-Host "Downloaded latest version of GL.cs";

$NewRawXMLToInsert = @'
<PropertyGroup>
  <!-- GL.cs configuration options! -->

  <!-- Profile: CORE/COMPAT -->
  <!-- COMPAT not implemented yet -->
  <OpenGLProfile>CORE</OpenGLProfile>

  <!-- Version: Any valid OpenGL version from 1.0-4.6 -->
  <OpenGLVersionMajor>3</OpenGLVersionMajor>
  <OpenGLVersionMinor>3</OpenGLVersionMinor>

  <!-- Defining exposed wrapper API (SAFE/UNSAFE/BOTH) -->
  <!-- SAFE: Only safe functions are exposed -->
  <!-- UNSAFE: Only unsafe functions are exposed -->
  <!-- BOTH: Both safe and unsafe functions are exposed -->
  <OpenGLWrapperAPI>BOTH</OpenGLWrapperAPI>

  <!-- Defining constants for compile time availability of APIs -->
  <DefineConstants>$(DefineConstants);OGL_V_$(OpenGLVersionMajor)_$(OpenGLVersionMinor);OGL_P_$(OpenGLProfile);OGL_WRAPPER_API_$(OpenGLWrapperAPI)</DefineConstants>
</PropertyGroup>
'@

# Add <AllowUnsafeBlocks>true</AllowUnsafeBlocks> to the first PropertyGroup in the .csproj file.
$FirstPropertyGroup = $CSProjFile.FirstChild.FirstChild;
$AllowUnsafeBlock = $FirstPropertyGroup.AppendChild($CSProjFile.CreateElement("AllowUnsafeBlocks"));
$AllowUnsafeBlock.InnerText = "true";

$NewNode = $CSProjFile.CreateDocumentFragment();
$NewNode.InnerXml = $NewRawXMLToInsert;

$CSProjFile.Project.AppendChild($NewNode);
$CSProjFile.Save("$ProjRoot\$CSProjFilePath");
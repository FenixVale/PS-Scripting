# Parameters

param (

[string]$EmailAddress,

[bool]$Impersonate = $false,

[bool]$UseAutodiscover = $true,

[bool]$UseDefaultCredentials = $true,

[bool]$TrustAllCertificates = $true,

[string] $Username,

[string] $Password,

[string] $Domain,

[string]$EwsUrl,

[string]$EWSManagedApiPath = "C:\Program Files (x86)\Microsoft\Exchange\Web Services\2.0\Microsoft.Exchange.WebServices.dll"

);

if ($TrustAllCertificates -eq $true)

{

## Code From http://poshcode.org/624

## Create a compilation environment

$Provider=New-Object Microsoft.CSharp.CSharpCodeProvider

$Compiler=$Provider.CreateCompiler()

$Params=New-Object System.CodeDom.Compiler.CompilerParameters

$Params.GenerateExecutable=$False

$Params.GenerateInMemory=$True

$Params.IncludeDebugInformation=$False

$Params.ReferencedAssemblies.Add("System.DLL") | Out-Null

$TASource=@'

  namespace Local.ToolkitExtensions.Net.CertificatePolicy{

    public class TrustAll : System.Net.ICertificatePolicy {

      public TrustAll() {

      }

      public bool CheckValidationResult(System.Net.ServicePoint sp,

        System.Security.Cryptography.X509Certificates.X509Certificate cert,

        System.Net.WebRequest req, int problem) {

        return true;

      }

    }

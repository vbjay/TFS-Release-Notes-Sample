function Create-RSAManagedObject($csp) {
    $rsaManaged = New-Object "System.Security.Cryptography.RSACryptoServiceProvider" -ArgumentList $csp 
    $rsaManaged.PersistKeyInCsp=$true
    $rsaManaged
}

function Encrypt-String($rsa, $unencryptedString) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($unencryptedString)
    [byte[]] $fullData =  $rsa.Encrypt($bytes,$true)
    [System.Convert]::ToBase64String($fullData)
}
function Decrypt-String($rsa, $encryptedString) {
    $bytes = [System.Convert]::FromBase64String($encryptedString)
    $unencryptedData=$rsa.Decrypt($bytes ,$true)
    [System.Text.Encoding]::UTF8.GetString($unencryptedData).Trim([char]0)
}
function Get-ReleaseNotesCSP()
{

$csp = New-Object System.Security.Cryptography.CspParameters
$csp.KeyContainerName = "{dd1cacd9-a0a1-4217-a6b9-40833ae1a4b1}"
$csp.Flags = $csp.flags -bor [System.Security.Cryptography.CspProviderFlags]::UseUserProtectedKey
$csp

}
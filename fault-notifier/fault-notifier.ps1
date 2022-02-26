# cd C:\Users\basha\OneDrive\work\pg\fault-notifier
# powershell -NoProfile -ExecutionPolicy Unrestricted .\fault-notifier.ps1

$user      = $env:USERNAME

$path_self = $MyInvocation.MyCommand.path
$path_this = Split-Path $path_self -Parent
$path_base = Split-Path $path_this -Parent

$file_self = Split-Path $path_self -Leaf
$dir_this  = Split-Path $path_this -Leaf
$dir_base  = Split-Path $path_base -Leaf



function global:Toast {
    param ([Parameter(Mandatory)][String] $title,[Parameter(Mandatory)][String] $msg ,[String] $url )
    $AppId = "{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe";
    $template = "<toast>";

    $template += @"
        <visual>
          <binding template="ToastGeneric">
            <text>$($title)</text>
            <text>$($msg)</text>
          </binding>
        </visual>
"@;

    if( $url ){
      $template += "<actions> <action content=`"Webƒy[ƒW‚ðŠJ‚­`" arguments=`"$($url)`" activationType=`"protocol`"/> </actions> ";
    }


    $template += "</toast>";

    [void][Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime];
    $xml=new-object Windows.Data.Xml.Dom.XmlDocument;
    $xml.loadXml($template);
    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]::CreateToastNotifier($AppId).Show($xml);
}


$url_status = "https://sakura01.prosper2.org/status/status.json";
$status = invoke-restmethod -uri $url_status -method get ;

# Slack Status
if( $status.slack -ne 'True' ){
  $service = "Slack";
  $title = $service + " Outage Report";
  $msg  = "There is an outage in "+$service ;
  $msg += "Start the migration process.";
  $url = "http://www.google.co.jp/";
  Toast -title $title -msg $msg -url $url;
}


# Azure DevOps Status
if( $status.AzureDevOps -ne 'True' ){
  $service = "Azure DevOps";
  $title = $service + " Outage Report";
  $msg  = "There is an outage in "+$service ;
  Toast -title $title -msg $msg ;
}



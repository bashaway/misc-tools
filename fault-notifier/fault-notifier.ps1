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
      $template += "<actions> <action content=`"Webページを開く`" arguments=`"$($url)`" activationType=`"protocol`"/> </actions> ";
    }


    $template += "</toast>";

    [void][Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime];
    $xml=new-object Windows.Data.Xml.Dom.XmlDocument;
    $xml.loadXml($template);
    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]::CreateToastNotifier($AppId).Show($xml);
}




# 全員で外部APIのstatusAPIをたたきまくるのはマズいので
# 内部サーバーが代表して取得し、その結果を全員が取得する。

# Slack Status
$url_status_slack = "https://status.slack.com/api/v2.0.0/current";
$status_slack = invoke-restmethod -uri $url_status_slack -method get;

if( $status_slack.status -ne 'ok' ){
  $service = "slack";
  $title = $service + "障害検知";
  $msg  = $service + "で障害が検知されました`n";
  $msg += "対応を開始してください";
  $url = "http://www.google.co.jp/";
  Toast -title $title -msg $msg -url $url;
}


# Azure DevOps Status
$url_status_ado = "https://status.dev.azure.com/_apis/status/health";
$status_ado = invoke-restmethod -uri $url_status_ado -method get;

if( $status_ado.status.health -ne 'healthy' ){
  $service = "Azure DevOps";
  $title = $service + "障害検知";
  $msg  = $service + "で障害が検知されました`n";
  Toast -title $title -msg $msg ;
}


<?php 
$app = "sickbeard";
$appname = "SickBeard";
$appversion = "0.507.63-1";
$appsite = "http://sickbeard.com/";
$apphelp = "http://sickbeard.com/forums/viewforum.php?f=7";

$applogs = array("/tmp/DroboApps/".$app."/log.txt",
                 "/tmp/DroboApps/".$app."/".$app.".log");

$appprotos = array("http");
$appports = array("8082");
$droboip = $_SERVER['SERVER_ADDR'];
$apppage = $appprotos[0]."://".$droboip.":".$appports[0]."/";
if ($publicip != "") {
  $publicurl = $appprotos[0]."://".$publicip.":".$appports[0]."/";
} else {
  $publicurl = $appprotos[0]."://public.ip.address.here:".$appports[0]."/";
}
$portscansite = "http://mxtoolbox.com/SuperTool.aspx?action=scan%3a".$publicip."&run=toolpage";
?>

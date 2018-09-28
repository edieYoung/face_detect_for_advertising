<?php
$con = mysql_connect("localhost","root","edie1219");
if (!$con)
{
 die('Could not connect: ' . mysql_error());
}
 $data = $_GET;
 $value = $data["value"];
mysql_select_db("ad_test", $con);
$sql="INSERT INTO test_data (gender,age,smilescore,smile,emotion,race, lefteye, righteye, leftglass, rightglass, leftsunglass, rightsunglass, pitchangle,rollangle,yawangle,adName,preference
) VALUES ($value)";

if (!mysql_query($sql,$con))
{
 die('Error: ' . mysql_error());
}


//$myfile = fopen('/Users/edieyoung/Desktop/graduateThesis/Advertisement_Classification/data/consumer.txt', "w") or exit("Unable to open file!");
//fwrite($myfile, $value);
//fclose($myfile);
exec("sudo /Users/edieyoung/anaconda2/bin/python /Users/edieyoung/Desktop/graduateThesis/Advertisement_Classification/src/writetotxt.py");
exec("sudo /Users/edieyoung/anaconda2/bin/python /Users/edieyoung/Desktop/graduateThesis/Advertisement_Classification/src/forwardPredict.py",$out,$s);
//echo exec('whoami');
//echo ($s);
echo $out[0];
mysql_close($con)
?>

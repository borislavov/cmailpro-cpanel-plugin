<?php 
$url="";
$cgpurl="";
if ($_SERVER['SERVER_PORT']==2083) {
        $url = "https://webmail.cmailpro.net/cgi-bin/login.pl";
        $cgpurl ="https://webmail.cmailpro.net/";
}
if ($_SERVER['SERVER_PORT']==2082) {
        $url = "http://webmail.cmailpro.net/cgi-bin/login.pl";
        $cgpurl ="http://webmail.cmailpro.net/";
}
if ($_SERVER['SERVER_PORT']==2096) {
	$url = "https://webmail.cmailpro.net/cgi-bin/login.pl";
	$cgpurl ="https://webmail.cmailpro.net/";
}
if ($_SERVER['SERVER_PORT']==2095) {
        $url = "http://webmail.cmailpro.net/cgi-bin/login.pl";
	$cgpurl ="http://webmail.cmailpro.net/";
}
?>
<FORM id="webform" action="<?php echo($url);?>" method="post">
  <input type="hidden" name="user" value="<?php echo($_SERVER["REMOTE_USER"]);?>" />
  <input type="hidden" name="cgpurl" value="<?php echo($cgpurl);?>" />
  <input type="hidden" name="pass" value="<?php echo($_SERVER["REMOTE_PASSWORD"]);?>"  />
 </form>

<script type="text/javascript">
	document.getElementById('webform').submit();
</script>

<?php 
$url="";
$cgpurl="";
if ($_SERVER['SERVER_PORT']==2083) {
        $url = "https://pronto.cmailpro.net/";
}
if ($_SERVER['SERVER_PORT']==2082) {
        $url = "http://pronto.cmailpro.net/";
}
if ($_SERVER['SERVER_PORT']==2096) {
        $url = "https://pronto.cmailpro.net/";
}
if ($_SERVER['SERVER_PORT']==2095) {
        $url = "http://pronto.cmailpro.net/";
}
?>

<script type="text/javascript">
  document.location.href = "<?php echo($url);?>";
</script>

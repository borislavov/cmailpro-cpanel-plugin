#!/bin/sh
 eval 'if [ -x /usr/local/cpanel/3rdparty/bin/perl ]; then exec /usr/local/cpanel/3rdparty/bin/perl -x -- $0 ${1+"$@"}; else exec /usr/bin/perl -x $0 ${1+"$@"}; fi;'
    if 0;
#!/usr/bin/perl

use Cpanel::LiveAPI ();
use CGI;
use Cpanel::CPAN::MIME::Base64::Perl qw(decode_base64);
use Cpanel::Wrap;
my $q = CGI->new;

my $cpanel = Cpanel::LiveAPI->new();
print "Content-type: text/html\r\n\r\n";
my $result = Cpanel::Wrap::send_cpwrapd_request(
    'namespace' => 'CGPro',
    'module'    => 'cca',
    'function'  => 'GETLOGIN',
    'data' =>  `whoami`
    );
if ( defined( $result->{'data'} ) ) {
    $loginData = $result->{'data'};
} else {
    die ("Can't login to CGPro: " . $result->{'error'});
}
my ($host, undef, undef, undef) = split "::", $loginData;

if ($host =! m/^(localhost|127\.0\.0)/) {
    $host = $ENV{'SERVER_ADDR'};
}

my $url, $cgurl;
if ($ENV{HTTPS} eq 'on') {
    $url = "https://pronto.cmailpro.net/cgi-bin/loginPronto.pl";
    $cgpurl = "https://pronto.cmailpro.net/";
} else {
    $url = "http://pronto.cmailpro.net/cgi-bin/loginPronto.pl";
    $cgpurl = "http://pronto.cmailpro.net/";
}

print <<EOF
	  <html>
	    <head>
	      <title>Redirect</title>
	    </head>
	    <body>
	      <form id="webform" action="$url" method="post">
		<input type="hidden" name="user" value="$ENV{'REMOTE_USER'}" />
		<input type="hidden" name="cgpurl" value="$cgpurl" />
		<input type="hidden" name="pass" value="$ENV{'REMOTE_PASSWORD'}"  />
	      </form>

	      <script type="text/javascript">
		document.getElementById('webform').submit();
	      </script>
	    </body>
	  </html>
EOF
;
$cpanel->end();

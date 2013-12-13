#!/bin/sh
 eval 'if [ -x /usr/local/cpanel/3rdparty/bin/perl ]; then exec /usr/local/cpanel/3rdparty/bin/perl -x -- $0 ${1+"$@"}; else exec /usr/bin/perl -x $0 ${1+"$@"}; fi;'
    if 0;
#!/usr/bin/perl

use Cpanel::LiveAPI ();
use CGI;
use Cpanel::CPAN::MIME::Base64::Perl qw(decode_base64);
my $q = CGI->new;

my $cpanel = Cpanel::LiveAPI->new();
print "Content-type: text/html\r\n\r\n";

my $url, $cgurl;
if ($ENV{HTTPS} eq 'on') {
    $url = "https://webmail.cmailpro.net/cgi-bin/login.pl";
    $cgpurl = "https://webmail.cmailpro.net/";
} else {
    $url = "http://webmail.cmailpro.net/cgi-bin/login.pl";
    $cgpurl = "http://webmail.cmailpro.net/";
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

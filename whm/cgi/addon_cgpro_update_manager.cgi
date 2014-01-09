#!/bin/sh
 eval 'if [ -x /usr/local/cpanel/3rdparty/bin/perl ]; then exec /usr/local/cpanel/3rdparty/bin/perl -x -- $0 ${1+"$@"}; else exec /usr/bin/perl -x $0 ${1+"$@"}; fi;'
    if 0;
#!/usr/bin/perl
#WHMADDON:appname:CGPro <strong>Update Manager</strong>

use Cpanel::Form            ();
use Whostmgr::HTMLInterface ();
use Whostmgr::ACLS          ();
use Cpanel::API::Branding        ();
use LWP::UserAgent;
use JSON;

$VERSION = '3.0.2-1';

print "Content-type: text/html\r\n\r\n";

Whostmgr::HTMLInterface::defheader( "CGPro Update Manager",'', '/cgi/addon_cgpro_update_manager.cgi' );

my $ua = LWP::UserAgent->new;
$ua->timeout(10);

my $response = $ua->get('https://api.github.com/repos/borislavov/cmailpro-cpanel-plugin/commits');

if ($response->is_success) {
    my $commits_json = $response->decoded_content;  # or whatever
    my $commits = decode_json $commits_json;
    my $commit_date = $commits->[0]->{commit}->{committer}->{date};
    my $commit_sha = $commits->[0]->{sha};
    # print $commit_sha;
    my $current_version = "Unknown";
    if (-f "/var/cpanel/cmailproVersion") {
	open(FI, "<", "/var/cpanel/cmailproVersion");
	$current_version = <FI>;
	close(FI);
    }
    print <<EOF
    <table summary="versions" cellpadding="5">
      <tr>
	<td><strong>Curent Version</strong></td>
	<td><code>$current_version</code>
	</td>
      </tr>
      <tr>
	<td><strong>Available version</strong></td>
	<td><code>$commit_sha ($commit_date)</code>
	</td>
      </tr>
    </table>

EOF
;
    my %FORM = Cpanel::Form::parseform();
    if ($FORM{'upgrade'}) {
	print "<h2>Downloading files</h2>";
	print "<pre>\n";
	$response = $ua->get("https://github.com/borislavov/cmailpro-cpanel-plugin/archive/master.tar.gz", ':content_file' => "/usr/src/cmailpro-cpanel-plugin-master-$commit_sha.tar.gz");
	if ($response->is_success) {
	    print "Download successful. '/usr/src/cmailpro-cpanel-plugin-master-$commit_sha.tar.gz' \n";
	    if ( -d '/usr/src/cmailpro-cpanel-plugin-master' ) {
		system("rm -rf /usr/src/cmailpro-cpanel-plugin-master");
	    }
	    print "Extracting files...\n";
	    system ("cd /usr/src ; tar -xzf /usr/src/cmailpro-cpanel-plugin-master-$commit_sha.tar.gz; cd cmailpro-cpanel-plugin-master; /bin/bash ./upgrade.sh");
	    open(FO, ">", "/var/cpanel/cmailproVersion");
	    print FO "$commit_sha ($commit_date)";
	    close(FO);
	} else {
	    print "Error while downloading package: <em>" . $response->status_line . "</em>";
	}
	print "</pre>\n";
    } else {
	print '<form action="" method="post">';
	print '<input type="submit" value="Upgrade Now!" name="upgrade" />';
	print '</form>';
    }
} else {
    print "<p>Cannot get version from server: <em>" . $response->status_line . "</em></p>";
}

1;

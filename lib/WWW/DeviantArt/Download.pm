package WWW::DeviantArt::Download;

use Data::Dumper;
use HTML::Entities;
use JSON::XS;
use LWP::UserAgent;
use Path::Tiny;
use URI::Escape;

our $VERSION = 0.1;

sub new {
	my $class = shift;
	my $self = bless {
		ua	=> LWP::UserAgent->new( agent => 'libwww-perl/'. $LWP::UserAgent::VERSION . '+' . __PACKAGE__.'/'.$VERSION, parse_head => 0 ),
		debug	=> undef,
		@_
	}, $class;

	print Data::Dumper::Dumper($self) if $self->{debug} && $self->{debug} > 1;

	return $self;
}

sub check_url_support {
	return 1 if $_[1] !~ /\.deviantart\.com\//i; # simplistic
};

sub download {
	my ($self, $url) = @_;

	my $error = $self->check_url_support($url);
	return "URL '$url' does not look like a deviantart URL or is not supported!" if $error;

	## fetch oEmbed JSON
	my $json = $self->fetch_oembed_json($url);
	return "Could not fetch and decode json!" unless $json;

	## fetch containing HTML page, optionally
	my $meta = $self->{process_html} ? $self->fetch_html($url) : {};

	## isolate title
	my $title = $json->{title};
	print "WWW::DeviantArt::Download: title is: ". $title ."\n" if $self->{debug};

	## download file
	my $filename = path($json->{url})->basename;
	print "WWW::DeviantArt::Download: downloading to $filename ..." if $self->{debug};
	return "File '$filename' exists/has already been downloaded!" if -f $filename && !$self->{force_download};
	$response = $self->{ua}->get($json->{url}, ':content_file' => $filename );

	unless($response->is_success){
		print " Error downloading URL '': ". $response->status_line ."\n" if $self->{debug};
		return " Error downloading URL '': ". $response->status_line ."\n";
	}
	print " OK\n" if $self->{debug};
	print " ". Dumper($response->headers) ."\n" if $self->{debug} && $self->{debug} > 1;

	if(wantarray){
		return 0, {
			%{ $meta },
			%{ $json },
			local_filename	=> $filename,
			last_modified	=> $response->header('last-modified'), # dA seems to provide the 'date posted' reliably via Last-Modified HTTP Header
			content_length	=> $response->header('content-length'),
		}
	}else{
		return 0;
	}
}

sub fetch_oembed_json {
	my $self = shift;
	my $url = shift;
	my $oembed_url = "http://backend.deviantart.com/oembed?url=".uri_escape($url);

	print "WWW::DeviantArt::Download::fetch_oembed_json: $oembed_url (for $url) ... " if $self->{debug};

	my $response = $self->{ua}->get($oembed_url);
 
	unless($response->is_success) {
		print "WWW::DeviantArt::Download::fetch_oembed_json: Error: ".$response->status_line."\n" if $self->{debug};
		return;
	}

	print " OK\n" if $self->{debug};
	my $json = JSON::XS::decode_json( $response->decoded_content( charset => 'none') ); # only decompress, but content already is encoded utf8

	print 'WWW::DeviantArt::Download::fetch_oembed_json: '.Data::Dumper::Dumper($json) if  $self->{debug} && $self->{debug} > 1;
	return $json;
}

sub fetch_html {
	my $self = shift;
	my $url = shift;
	print "WWW::DeviantArt::Download::fetch_html: $url ... " if $self->{debug};

	my $response = $self->{ua}->get($url);
 
	unless($response->is_success) {
		print "WWW::DeviantArt::Download::fetch_html: Error: ".$response->status_line."\n" if $self->{debug};
		return;
	}

	print " OK\n" if $self->{debug};

	my @lines = split(/\n/, $response->decoded_content( charset => 'none') );  # only decompress, but content already is encoded utf8

	# simplistic parse, and let's cheat and get (surely truncated) description from <head>
	my $line;
	for(@lines){
		$line = $_;
		last if $_ =~ /\Q<meta name="og:description\E/;
	}
	# print " line is $line \n";
	my ($junk, $description) = split(/ content="/, $line);
	my ($description) = split(/">/, $description);
	my $meta = { description => decode_entities($description) };

	print 'WWW::DeviantArt::Download::fetch_html: '.Data::Dumper::Dumper($meta) if  $self->{debug} && $self->{debug} > 1;
	return $meta;
}

1;

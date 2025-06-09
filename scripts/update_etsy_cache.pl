#!/usr/bin/perl
use strict;
use warnings;
use LWP::UserAgent;
use JSON;
use DateTime;
use Log::Log4perl;
use File::Path qw(make_path);
use FindBin qw($Bin);
use File::Spec;

# Version info
our $VERSION = '1.0.0';

# Config - relative paths from script location
my $BASE_DIR = File::Spec->catdir($Bin, '..');
my $CACHE_DIR = File::Spec->catdir($BASE_DIR, 'public', 'data');
my $LOG_DIR = File::Spec->catdir($BASE_DIR, 'public', 'logs');
my $CACHE_FILE = File::Spec->catfile($CACHE_DIR, 'listings.json');
my $API_KEY = $ENV{ETSY_API_KEY};
my $SHOP_ID = $ENV{ETSY_SHOP_ID};

# Setup directories
make_path($CACHE_DIR, $LOG_DIR);

# Initialize logging
Log::Log4perl->init({
    'log4perl.rootLogger' => 'INFO, File',
    'log4perl.appender.File' => 'Log::Log4perl::Appender::File',
    'log4perl.appender.File.filename' => File::Spec->catfile($LOG_DIR, 'etsy_cache.log'),
    'log4perl.appender.File.layout' => 'Log::Log4perl::Layout::PatternLayout',
    'log4perl.appender.File.layout.ConversionPattern' => '%d %p %m%n'
});

my $logger = Log::Log4perl->get_logger();
$logger->info("Starting cache update (v$VERSION)");

# Fetch and cache
my $ua = LWP::UserAgent->new(timeout => 30);
my $response = $ua->get(
    "https://openapi.etsy.com/v3/application/shops/$SHOP_ID/listings/active",
    'x-api-key' => $API_KEY
);

if ($response->is_success) {
    my $data = {
        timestamp => DateTime->now->iso8601,
        listings => decode_json($response->content)->{results}
    };
    
    open my $fh, '>', $CACHE_FILE or die "Cannot open $CACHE_FILE: $!";
    print $fh encode_json($data);
    close $fh;
    
    $logger->info("Cache updated successfully");
    chmod 0644, $CACHE_FILE;
} else {
    $logger->error("Failed to fetch: " . $response->status_line);
}
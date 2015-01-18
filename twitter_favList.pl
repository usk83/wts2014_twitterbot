#!/usr/bin/perl
use strict;
# use warnings;
use Net::Twitter;
use Encode;
use utf8;
use Data::Dumper;

binmode(STDOUT,":encoding(utf-8)");

#######################################################
# Net::Twitter 初期設定
#######################################################

# consumer_key / access_token
my $consumer_key        = 'd3taW2RbAYBQod8vSH8rO0QNL';
my $consumer_key_secret = 'vQJ8DaB9LwEYYbnnNgbLVVvkbDrC9ihgvtu9k1woTtyeHcpdVQ';
my $access_token        = '2938502330-LHviM5sgMeJeX4coX5aDzQkdGy6kWBETRNyHIGG';
my $access_token_secret = 'ZEEaeegdR99io4CAyiSAttzWaTpYteppLWy7HUZa53ZYA';

# Net::Twitter
my $twitter = Net::Twitter->new(
	traits          => [qw/API::RESTv1_1/],
	consumer_key    => $consumer_key,
	consumer_secret => $consumer_key_secret,
	access_token    => $access_token,
	access_token_secret => $access_token_secret,
	ssl => 1
);

################################################
# favリストの取得
################################################
my %param = (
	# user_id => wts2014team6,
	count => 150
);

my $res = $twitter->favorites({%param});

my $i = 1;

open(OUT,">favList_usersbio.csv") || die "ERROR: $!";
binmode(OUT,":encoding(utf-8)");

for my $status (@{$res})
{
	my $bio = "$status->{user}->{description}";
	$bio =~ s/\r//;
	$bio =~ s/\n//;
	chomp ($_);

	print OUT "$i,$status->{user}->{screen_name},$bio,$status->{favorite_count},$status->{retweet_count}\n";
	$i++;
}

close(OUT);

#レスポンスをダンプ
# print Dumper $res;

# end of file

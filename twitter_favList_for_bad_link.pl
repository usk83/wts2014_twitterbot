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
my $consumer_key        = 'YB0gZaWut1GJOE3wKUmRV7Jyd';
my $consumer_key_secret = 'CnvU0TmrhTZxvz58T04m8vySkoDdnIEQUm9f2KN8Llhl2OQQMJ';
my $access_token        = '2589042564-rwbst94lYmTOYE1az8FvKL44JgTUaiNE3iaXHke';
my $access_token_secret = '22STmXmvGSDJCJlMqwyvQ2s04Ea6KtqLt3s7O8VSiItww';

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

open(OUT,">bad_tweet_link.txt") || die "ERROR: $!";
binmode(OUT,":encoding(euc-jp)");

for my $status (@{$res})
{
	print Dumper $status->{entities}->{urls};

	if ($status->{entities}->{urls}[0]->{expanded_url})
	{
		print OUT "$i,$status->{entities}->{urls}[0]->{expanded_url}\n";
	}
	else
	{
		print OUT "$i,$status->{entities}->{media}[0]->{display_url}\n";
	}
	$i++;
}

# close(OUT);

#レスポンスをダンプ
# print Dumper $res;

# end of file

#!/usr/bin/perl
use strict;
# use warnings;
use Net::Twitter;
use Encode;
use utf8;
use Data::Dumper;

binmode(STDOUT,":encoding(utf-8)");

####################################################
# Net::Twitter 初期設定
####################################################

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
# とりあえず検索
################################################

sub getSinceDate()
{
	my $cur_time = time;
	my $time = $cur_time  - 1*86400 ;
	my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time) ;
	my $since_date = sprintf("%02d",$mday) ;
	$year = $year + 1900 ;
	$mon = $mon + 1 ;
	$mon = sprintf("%02d",$mon) ;
	$since_date = $year."-".$mon."-".$since_date ;
	return $since_date;
}

my $since_date_param = getSinceDate();

# $since_id の定義
open(IN,"since_id.csv") || die "ERROR: $!";
binmode(IN,":encoding(utf-8)");
my $since_id = <IN>;
if (!defined($since_id)) { $since_id = 0; }

# langはja、countは未定(max==100)、since_idは最終的には使用
# since_idで過去に検索したものを検索しない用にする
my %param = (
	lang => 'ja',
	count => 10,
	# since_id => $since_id,
	# since => $since_date_param,
	# page => $page,
	# rpp => 100,
);

# 分析結果から決定
my $search_term = 'ツインライナー';
# my $search_term = '湘南藤沢キャンパス';
# $search_term .= ' OR 三田キャンパス';
$search_term .= ' filter:links';

print "$search_term";


my $res = $twitter->search($search_term, {%param});

my $i = 1;
my $tmp_since_id;

for my $status (@{$res->{statuses}})
{
	if (!defined($tmp_since_id))
	{
		$tmp_since_id = "$status->{id}";
	}

	print("($i)\@$status->{user}->{screen_name}: $status->{text}\
		\n$status->{created_at}\n\
		$status->{id}\n\
		fav: $status->{favorite_count}\n\
		ret: $status->{retweet_count}\n\
		\n\n");
	$i++;
}

# $tmp_since_id をファイルに書き込んでおく
if(defined($tmp_since_id))
{
	open(OUT,">since_id.csv") || die "ERROR: $!";
	binmode(OUT,":encoding(utf-8)");
	print OUT "$tmp_since_id";
	close(OUT);
}

#レスポンスをダンプ
# print Dumper $res;



# 特定のツイートをリツイートする
# my $id = 556477381569806337;
# $twitter->retweet($id);





# url を含むツイートからurlを抽出する(お試し)
# my @URL;
# my $test = $res->{statuses};
# foreach my $line (@$test)
# {
# 	@URL = $line->{text};
# 	foreach my $url (@URL)
# 	{
# 		if ($url =~ /(http:\/\/\S+)(?:\s||\w)/i)
# 		{
# 				print encode('UTF-8',$1."\n");
# 		}
# 		#print encode('UTF-8',$url."\n");
# 	}
# }


####################################################
# mentionの取得(サンプル)
# 自分宛てのツイートを取得して表示
####################################################

# $option = { count => 10 };
# $mentions = $twitter->mentions($option);

# foreach $tweet (@{$mentions}){

#     # ツイートの情報を取得
#     $user = $tweet->{'user'}{'screen_name'};
#     $text = $tweet->{'text'};

#     print "$user $text\n";
# }

####################################################
# ツイート(サンプル)
####################################################

# $body = { status => 'tweet'};

# # 失敗する可能性があるものは eval で囲む
# eval {
#     $twitter->update($body);
# };

# if($@){ # $@ にevalのエラーメッセージが入っている
#     print "ERROR: cannot update $@\n";
# }

# end of file

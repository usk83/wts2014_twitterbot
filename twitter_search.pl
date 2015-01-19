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
# ハッシュ作成など
################################################
my @list;

#positive
my %pos_hash = ();
open(IN,"text_analysis/freq/good_tweet_freq.txt") || die "$!";
binmode(IN,":encoding(utf8)");
while(<IN>){
 chomp; # 読み込んだ行の改行文字を削除
 @list = split(/\t/); # タブ区切りで split
 $pos_hash{$list[1]} = $list[0]; # 単語と出現確率を表に格納
}
# ファイルを閉じる
close(IN);

#negative
my %neg_hash = ();
open(IN,"text_analysis/freq/bad_tweet_freq.txt") || die "$!";
binmode(IN,":encoding(utf8)");
while(<IN>){
 chomp; # 読み込んだ行の改行文字を削除
 @list = split(/\t/); # タブ区切りで split
 $neg_hash{$list[1]} = $list[0]; # 単語と出現確率を表に格納
}
# ファイルを閉じる
close(IN);

#positive
my %pos_bio_hash = ();
open(IN,"text_analysis/freq/good_bio_freq.txt") || die "$!";
binmode(IN,":encoding(utf8)");
while(<IN>){
 chomp; # 読み込んだ行の改行文字を削除
 @list = split(/\t/); # タブ区切りで split
 $pos_bio_hash{$list[1]} = $list[0]; # 単語と出現確率を表に格納
}
# ファイルを閉じる
close(IN);

#negative
my %neg_bio_hash = ();
open(IN,"text_analysis/freq/bad_bio_freq.txt") || die "$!";
binmode(IN,":encoding(utf8)");
while(<IN>){
 chomp; # 読み込んだ行の改行文字を削除
 @list = split(/\t/); # タブ区切りで split
 $neg_bio_hash{$list[1]} = $list[0]; # 単語と出現確率を表に格納
}
# ファイルを閉じる
close(IN);

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
# ファイルを閉じる
close(IN);

# langはja、countは未定(max==100)、since_idは最終的には使用
# since_idで過去に検索したものを検索しない用にする
my %param = (
	lang => 'ja',
	count => 100,
	since_id => $since_id,
	# since => $since_date_param,
	# page => $page,
	# rpp => 100,
);

# 分析結果から決定
my $search_term = 'イラスト OR 落書き OR さん OR ちゃん OR 色 OR 枚 OR 用 OR 時間 OR 先生 OR 練習 OR 絵描き OR 絵 OR キャラ OR カラー';

# my $search_term = '湘南藤沢キャンパス';
# $search_term .= ' OR 三田キャンパス';
# $search_term .= ' filter:links';

print "search_term:" . "$search_term\n";

my $res = $twitter->search($search_term, {%param});

my $i = 1;
my $tmp_since_id;
my @debug_statuses;
my $max_id = 0;
my %posted;
my @neg_c;
my @pos_c;
my @retweet_lists;

for my $status (@{$res->{statuses}})
{
	my $neg = 1;
	my $pos = 1;
	my $url_flg = 0;

	if (!defined($tmp_since_id))
	{
		$tmp_since_id = "$status->{id}";
	}

	#=================================================
	# ここから判定するところ
	#=================================================

	#RTすべきツイートか判定してリストに格納
	#すでにRTしてないもの、ログより古いものは除く
	if(!$posted{$status->{id}}){ # $max_id < $status->{id}

		if(index($status->{entities}->{media}[0]->{display_url},"pic.twitter.com") != -1){
			$url_flg = 1;
		}

		foreach my $key(keys(%pos_hash)) {
			# print "pos_hash:" . "$pos_hash{$key}" . "key:" . "$key";
			if(index($status->{text},$key) != -1){
				$pos *= $pos_hash{$key};
			}		
		}
		foreach my $key(keys(%pos_bio_hash)) {
			# print "pos_hash:" . "$pos_hash{$key}" . "key:" . "$key";
			if(index($status->{user}->{description},$key) != -1){
				$pos *= $pos_bio_hash{$key};
			}	
		}		
		
		foreach my $key(keys(%neg_hash)) {
			# print "neg_hash:" . "$neg_hash{$key}" . "key:" . "$key";
			if(index($status->{text},$key) != -1){
				$neg *= $neg_hash{$key};
			}
		}
		foreach my $key(keys(%neg_bio_hash)) {
			# print "neg_hash:" . "$neg_hash{$key}" . "key:" . "$key";
			if(index($status->{user}->{description},$key) != -1){
				$neg *= $neg_bio_hash{$key};
			}
		}

		#条件指定
		if( $neg == 1 && $pos > 3000 && $url_flg){# && $status->{favorite_count} > 3 
			$max_id = $status->{id};
			push(@retweet_lists,$status->{id});
			push(@debug_statuses,$status);
			$posted{$status->{id}} = 1;
			push(@pos_c,$pos);
			push(@neg_c,$neg);
		}
	}

	# print("($i)\@$status->{user}->{screen_name}: $status->{text}\
	# 	\n$status->{created_at}\n\
	# 	$status->{id}\n\
	# 	fav: $status->{favorite_count}\n\
	# 	ret: $status->{retweet_count}\n\
	# 	\n\n");
	# $i++;
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
# print Dumper $res->{search_metadata}->{query};


my $x = 0;
#リストの内容を表示（デバッグ用）
for my $debug_status(@debug_statuses) {
	

	print("($i)\@$debug_status->{user}->{screen_name}: $debug_status->{text}\
	\n$debug_status->{created_at}\n\
	$debug_status->{id}\n\
	neg: $neg_c[$x]\n\
	pos: $pos_c[$x]\n\
	fav: $debug_status->{favorite_count}\n\
	ret: $debug_status->{retweet_count}\n\
	\n\n");

	$x++;
}


# 特定のツイートをリツイートする
foreach my $retweet_list(@retweet_lists) {
	$twitter->retweet($retweet_list);
}





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
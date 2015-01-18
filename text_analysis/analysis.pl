#!/usr/bin/perl

use utf8;
use Encode;

binmode(STDOUT,":encoding(utf-8)");

# 頻度を格納する連想配列
%hash = ();

# okashira.txt.chasen の読み込み
open(IN,"bad_tweet/bad_tweet.chasen") || die "ERROR: $!";

binmode(IN,":encoding(euc-jp)");

while(<IN>)
{
	chomp;

	# 読み込んだ行が EOS (文末)の場合
	if(/^EOS/)
	{}
	else
	{
		@list = split(/\t/);

		# 名詞の場合だけ頻度表を更新する
		if($list[3] =~ /名詞/){
			# すでに連想配列に単語が入っている場合
			if(defined($hash{$list[0]}))
			{
				# 単語の頻度を１増やす
				$hash{$list[0]}++;
			}
			else
			{
				# 単語の頻度を１にする
				$hash{$list[0]} = 1;
			}
		}
	}
}

close(IN);

# 連想配列のキー（表の左側）を一つずつ $word という変数に入れて処理
foreach $word (keys %hash){
	# 単語，頻度を表示
	if ($hash{$word} >= 5)
	{
		print "$hash{$word}\t$word\n";
	}
}

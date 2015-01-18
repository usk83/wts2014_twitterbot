webテキスト処理法 最終製作
=================================

## チームインフォメーション
- Team: 6
- Name: どらい
- Member: 高橋、原、細田、今野

## プログラムの処理の流れ

リツイートの場合にも検索にかかってしまう → 重複の恐れ → リツイートかどうかの判定、及びリツイートの場合の処理

## 検索に有用なワード

◎描けた
○イラスト
○落書き
△絵描き
△かいた
△絵


## パラメータとなる値（searchで得られる値）

###### ユーザー名
$status->{user}->{screen_name}
→ 評価無し
###### ツイート内容
$status->{text}
→ 今から分析
###### ツイート日時
$status->{created_at}
→ 評価無し
###### ツイート固有のid
$status->{id}
→ 評価無し
###### ツイートのお気に入り数
$status->{favorite_count}
→ 任意の値で評価
###### ツイートのリツイート数
$status->{retweet_count}
→ 任意の値で評価
###### リプライ数
不明
→ 取得しない
###### リプライの内容一覧
不明
→ 取得しない
###### ツイート発信者のフォロワー数
$status->{user}->{followers_count}
→ 任意の値で評価
###### ツイート発信者のbio
$status->{user}->{description}
→ 調査


## Twitterアカウント情報
ID: `wts2014team6`

Pass: `OIxh6m9U`

Consumer Key: `d3taW2RbAYBQod8vSH8rO0QNL`

Consumer Secret: `vQJ8DaB9LwEYYbnnNgbLVVvkbDrC9ihgvtu9k1woTtyeHcpdVQ`

Access Token: `2938502330-LHviM5sgMeJeX4coX5aDzQkdGy6kWBETRNyHIGG`

Access Token Secret: `ZEEaeegdR99io4CAyiSAttzWaTpYteppLWy7HUZa53ZY`


## files

### 最終課題に関する諸注意
~/Desktop/wts_final/twitterBotCaution.pdf

### 進捗状況共有
[Google Docs](https://docs.google.com/document/d/1IrmpKlRST2ZbRKN1bPMK0l31srdaiePPsCx7kqMK02w/edit?usp=sharing "Google Docs")
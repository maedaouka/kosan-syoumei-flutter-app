# kosan_syoumei

twitterのユーザーUIDとAWSのQLDBを利用した、古参であることを証明するアプリです。
自分がいつから誰を応援しているのだと証明するための証明書を発行します。

## 構成

firebaseを利用してtwitter認証でログイン¥n
　　　　　　↓
ログイン時に取得した情報からtwitterAPIを叩く。（応援相手を入力する際にAPIを叩いてユーザー情報を取得しています。）
　　　　　　↓
AWSのAPIGateway　→　AWSのlambda →　QLDBアクセス

# kosan_syoumei

twitterのユーザーUIDとAWSのQLDBを利用した、古参であることを証明するアプリです。
自分がいつから誰を応援しているのだと証明するための証明書を発行します。

![kosan](https://user-images.githubusercontent.com/29334692/99350486-dae31580-28e1-11eb-8857-18c8a80da589.gif)

## 構成

firebaseを利用してtwitter認証でログイン

　　　　　↓

ログイン時に取得した情報からtwitterAPIを叩く。（応援相手を入力する際にAPIを叩いてユーザー情報を取得しています。）

　　　　　↓

AWSのAPIGateway　→　AWSのlambda →　QLDBアクセス

![Untitled Diagram](https://user-images.githubusercontent.com/29334692/108146172-132c0700-7110-11eb-875a-d2a770cc3031.jpg)


lambda のコード

作成
https://github.com/maedaouka/lambda_kosan_syoumei_create

一覧取得
https://github.com/maedaouka/lambda_kosan_syoumei_mylist

## 環境構築
flutterAppのインストール
https://flutter.dev/docs/get-started/install

パッケージがプロジェクトに取り込む
```
flutter pub get
```


iosのエミュレーターを起動する場合は、以下も実行。
```
cd ios
pod install
```

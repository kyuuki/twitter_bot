Twitter ボット
==============

[![Build status][shield-build]](#)
[![MIT licensed][shield-license]](#)
[![Rails][shield-rails]][rails]

Twitter に自動的に投稿するだけのボット。

## Table of Contents

* [Technologies](#technologies)
* [Demo](#demo)
* [Getting started](#getting-started)
* [Deployment](#deployment)
* [Usage](#usage)
* [References](#references)
* [License](#license)

## Technologies

* [Rails][rails] 5.2.6
* [PostgreSQL][postgresql]
* [Heroku][heroku]

## Demo

* [Heroku](https://kyuuki-twitter-bot-demo.herokuapp.com)  
  メールアドレス: bot@example.com, パスワード: twitter

## Getting started

### Rails 開発環境作成

```sh
$ git clone git@github.com:kyuuki/twitter_bot.git
$ cd twitter_bot
$ bundle install
$ rails db:create
$ rails db:migrate
```

### 管理ユーザー登録

```sh
$ rails c
> AdminUser.create(email: "bot@example.com", password: "twitter")
```

### Rails サーバー起動

```sh
$ rails s -b 0.0.0.0
```

## Deployment

Heroku にデプロイ

```sh
$ heroku create kyuuki-twitter-bot-demo
$ git push heroku master
$ heroku run rake db:migrate
```

## Usage

### 管理画面

#### ログイン

- "http://xxxxx:3000/" にアクセスし、管理ユーザー登録で登録したユーザーでログイン

#### Twitter アカウント登録

- "http://xxxxx:3000/twitter_accounts" にアクセスし、Twitter アカウントを登録

#### メッセージ登録

#### スケジュール登録

### Rake タスク

#### 単純投稿

```sh
$ rails twitter:post_first[<category>]
```

特定のカテゴリのメッセージを一つだけ投稿する。  
※メッセージにある曜日、投稿時間は無視。  
※スケジュールは無視。

#### スケジュールランダム投稿

```sh
$ rails twitter:schedule_post_random[<category>]
```

スケジュールの設定に基づき、メッセージをランダムに一つ投稿する。  
メッセージの有効期間以外は見ない。  
(10 分おきにこのタスクを動かす前提)

## References

* [Twitter API](https://developer.twitter.com/en/docs/twitter-api)

## License

This is licensed under the [MIT](https://choosealicense.com/licenses/mit/) license.  
Copyright &copy; 2021 [Fuji Programming Laboratory](https://fuji-labo.com/)



[rails]: https://rubyonrails.org/
[postgresql]: https://www.postgresql.org/
[heroku]: https://www.heroku.com/home

[shield-build]: https://img.shields.io/badge/build-passing-brightgreen.svg
[shield-license]: https://img.shields.io/badge/license-MIT-blue.svg
[shield-rails]: https://img.shields.io/badge/-Rails-CC0000.svg?logo=ruby-on-rails&style=flat

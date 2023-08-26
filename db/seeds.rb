# frozen_string_literal: true

# queue_adapterを変更している理由とtransactionを使っている理由は下記URLを参照
# https://bootcamp.fjord.jp/questions/779#answer_2262
ActiveStorage::AnalyzeJob.queue_adapter = :inline

print '開発環境のデータをすべて削除して初期データを投入します。よろしいですか？[Y/n]: ' # rubocop:disable Rails/Output
unless $stdin.gets.chomp.casecmp('Y').zero?
  puts '中止しました。' # rubocop:disable Rails/Output
  return
end

def picture_file(name)
  File.open(Rails.root.join("db/seeds/#{name}"))
end

def add_comments_to(commentable, contents)
  comment_count = [*0..3].sample
  times = Array.new(3) do
    Faker::Time.between(from: commentable.created_at.since(10.minutes), to: commentable.created_at.since(2.days))
  end.sort
  users = User.all.to_a
  comment_count.times do |n|
    time = times[n]
    user = users.sample
    content = contents.sample
    commentable.comments.create!(user:, content:, created_at: time, updated_at: time)
  end
end

puts '実行中です。しばらくお待ちください...' # rubocop:disable Rails/Output

Book.destroy_all

Book.transaction do # rubocop:disable Metrics/BlockLength
  Book.create!(
    title: 'Ruby超入門',
    memo: 'Rubyの文法の基本をやさしくていねいに解説しています。',
    author: '五十嵐 邦明',
    picture: picture_file('cho-nyumon.jpg')
  )

  Book.create!(
    title: 'チェリー本',
    memo: 'プログラミング経験者のためのRuby入門書です。',
    author: '伊藤 淳一',
    picture: picture_file('cherry-book.jpg')
  )

  Book.create!(
    title: '楽々ERDレッスン',
    memo: '実在する帳票から本当に使えるテーブル設計を導く画期的な本！',
    author: '羽生 章洋',
    picture: picture_file('erd.jpg')
  )

  50.times do
    Book.create!(
      title: Faker::Book.title,
      memo: Faker::Book.genre,
      author: Faker::Book.author,
      picture: picture_file('no-image.png')
    )
  end
end

User.destroy_all

User.transaction do
  50.times do |n|
    name = Faker::Name.name
    User.create!(
      email: "sample-#{n}@example.com",
      password: 'password',
      name:,
      postal_code: "123-#{n.to_s.rjust(4, '0')}",
      address: Faker::Address.full_address,
      self_introduction: "こんにちは、#{name}です。"
    )
  end
end

# 画像は読み込みに時間がかかるので一部のデータだけにする
User.order(:id).each.with_index(1) do |user, n|
  next unless (n % 8).zero?

  number = rand(1..6)
  image_path = Rails.root.join("db/seeds/avatar-#{number}.png")
  user.avatar.attach(io: File.open(image_path), filename: 'avatar.png')
end

Report.destroy_all

users = User.all.to_a
times = Array.new(55) { Faker::Time.between(from: 5.days.ago, to: 1.day.ago) }.sort
titles = <<~TEXT.lines(chomp: true)
  初日報です
  CSS初級
  gitに苦戦
  lsコマンドむずすぎへん？
  自作サービスに着手
  ペアプロ申し込んでみた
  やっとRails
  Sinatraの勉強
  Markdownって便利
  RSpec始めました
TEXT
contents = <<~TEXT.lines(chomp: true)
  自分が聴いだのは近頃途中でおもにないうでし。
  すなわち言葉か不明か反抗にしですて、事実末見識にきまってならなかっためにご談判の十月で知れうです。
  何だかひょろひょろは別に否によっているなば、私にも当時いっぱいなどあなたのお創設も若い得下さろるた。
  それも同年もっとその教育家というのの後がつけよただ。
  自己をところが岡田さんからしかしそうあるですのうでた。
  ほかでも単にして根ざしましないですますて。
  何しろはなはだなっば話もこうないます事ある。
  大分幾分お話を解るありやいるです事に黙っないです。
  しっかりの今度になってこの時でもっとも向いなかっなくと上るた事だ。
  深いませましがあまりご本場見るましものましなけれございます。
TEXT
Report.transaction do
  55.times do |n|
    time = times[n]
    user = users.sample
    title = titles.sample
    content_length = [*1..3].sample
    content = contents.sample(content_length).join("\n")
    user.reports.create!(title:, content:, created_at: time, updated_at: time)
  end
end

# dependent: :destroy で全件削除されているはずだが念のため
Comment.destroy_all

ApplicationRecord.transaction do # rubocop:disable Metrics/BlockLength
  contents = <<~TEXT.lines(chomp: true)
    これは面白そう。
    すごく実用的！
    画期的な内容ですね！
    私も読んでみます。
    ちょっと難しそうな本。
    とてもためになりました。
    人生について考えられました。
    これを読めばあなたも億万長者！！
    この作者の本はどれも面白い。
    わかりやすかったです。
  TEXT
  Book.all.each do |book|
    add_comments_to(book, contents)
  end

  contents = <<~TEXT.lines(chomp: true)
    なるほど、大変そうですね。
    わかります！！
    あるあるですね〜。
    一緒に頑張りましょう！
    へ〜、そうなんですね。
    それは意外ですw
    私も同じです〜。
    たしかに〜。
    勉強になります！
    ですよね〜。同感です。
  TEXT
  Report.all.each do |report|
    add_comments_to(report, contents)
  end
end

puts '初期データの投入が完了しました。' # rubocop:disable Rails/Output

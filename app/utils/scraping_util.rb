#
# スクレイピングユーティリティ
#
module ScrapingUtil
  require "open-uri"
  require "net/http"

  #
  # https://news.netkeiba.com/ 専用スクレイピング
  #
  # - jQuery の Ajax で JSONP 使ってページに埋め込んでる
  #
  def self.scrape_netkeiba
    url = "https://news.netkeiba.com/"
    path = "/?callback=xxx&pid=api_get_news_rank&input=UTF-8&output=jsonp&show_id=NewsNewsRankList&rank_type=4&category_id=3&subcategory_id=&template_prefix=main&limit=20&page=1&pager_type=more_outer&pager_url=?pid=news_backnumber&page=1"

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme === "https"

    response = http.get(path)

    if response.code != "200"
      Rails.logger.fatal "response.code = #{response.code}."
      raise
    end

    str = response.body
    # Callback 関数の引数のみを取り出す
    str = str.gsub(/^xxx\(/, "").gsub(/\)$/, "")
    # /uxxxx になっているのを UTF-8 に
    str = str.gsub(/\\u([\da-fA-F]{4})/) { [$1].pack("H*").unpack("n*").pack("U*") }
    # str が "xxx\nyyy" (ダブルクォーテーションも文字列の一部) になっているのを Ruby の文字列として扱う
    str = eval(str)  # rubocop:disable Security/Eval

    doc = Nokogiri::HTML.parse(str)

    # 1 つ目の記事取り出し
    div = doc.xpath("//div[@id='news-view-default']//div[@class='NewsList NetkeibaNewsList']")[0]

    url   = div.xpath(".//a").attribute("href").value
    title = div.xpath(".//h2").text

    return title, url
  end
end

require 'discordrb'
require 'dotenv'
require 'net/http'
require 'json'
# require 'awesome_print'

Dotenv.load
bot = Discordrb::Commands::CommandBot.new token: ENV['BOT_TOKEN'], prefix: '!'

bot.command :환율 do |event, *args|
  event.channel.send_embed do |embed|
    time = Time.new
    embed.title = "#{time.inspect} 기준 암호화폐 환율"
    embed.colour = 'F09F30'.to_i 16 # decimal

    # 코빗 https://api.korbit.co.kr/v1/ticker?currency_pair=$CURRENCY_PAIR
    # https://apidocs.korbit.co.kr/ko/#%EA%B1%B0%EB%9E%98%EC%86%8C-%EA%B3%B5%EA%B0%9C
    # currencies = %w(etc_krw eth_krw xrp_krw bch_krw)

    # 코인원 https://api.coinone.co.kr/ticker/
    # http://doc.coinone.co.kr/#api-Public-Ticker
    # Allowed values: btc, bch, eth, etc, xrp, qtum, iota, ltc, all

    req = Net::HTTP.get URI 'https://api.coinone.co.kr/ticker/?currency=all'
    res = JSON.parse req # parsed hash
    unless res['result'] == "success" and res['errorCode'] == "0"
      embed.description = 'parse error!'
    else
      embed.description = 'parse success!'
      currencies = {"btc" => "비트코인",
                    "bch" => "비트코인 캐시",
                    "eth" => "이더리움",
                    "etc" => "이더리움 클래식",
                    "xrp" => "리플",
                    "qtum" => "퀀텀",
                    "iota" => "아이오타",
                    "ltc" => "라이트코인"}
      currencies.each do |symbol, name|
        value = res[symbol]['last']
        embed_obj = Discordrb::Webhooks::EmbedField.new name: "#{name}(#{symbol.upcase})", 
                                                        value: "#{value.to_s.reverse.gsub(/...(?=.)/,'\&,').reverse} KRW", # alternatives?
                                                        inline: 'true'
        embed.fields.push embed_obj
        # debugging
        # ap embed_obj
      end
    end

    # debugging
    # ap embed.fields

    embed.footer = Discordrb::Webhooks::EmbedFooter.new text: "한강 가즈아~"
    # embed.timestamp = time
  end
end

bot.run

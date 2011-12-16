require 'sinatra/base'
require 'haml' 
require 'RMagick'
require 'open-uri'

class AdviceWelp < Sinatra::Base
  get '/' do
    haml :index
  end

  post '/' do
    redirect "/#{params[:top]}/#{params[:bottom]}/"
  end

  get '/:top/:bottom/' do
    haml :welp, :locals => params
  end

  get '/images/:top/:bottom' do
    img = Magick::Image.read('advicewelp.png').first
    params.each{|k,v| add_text(img, v, {"top"=>Magick::NorthGravity,"bottom"=>Magick::SouthGravity}[k])}
    content_type 'image/png'
    img.to_blob
  end

  get '/tinyurl/*' do
    tinyurl "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}/#{URI.encode(params[:splat][0])}/"
  end

  def add_text(img, text, pos)
    Magick::Draw.new.annotate(img, 0, 0, 3, 18, word_wrap(text)) do
      self.font = 'Arial'
      self.pointsize = 36
      self.font_weight = Magick::BoldWeight
      self.fill = 'white'
      self.stroke = 'black'
      self.gravity = pos
    end
  end

  def word_wrap(text)
    text.gsub(/(.{1,15})(?: +|$)\n?|(.{15})/, "\\1\\2\n").chomp.upcase
  end

  helpers do  
    def tinyurl(url)
      open("http://tinyurl.com/api-create.php?url=#{url}").read
    end
  end
end

%w(sinatra haml RMagick open-uri).each{|lib| require lib}
#require 'sinatra'
#require 'haml'
#require 'RMagick'
#require 'open-uri'

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
  magick_image 'advicewelp.png', params[:top], params[:bottom]
end

get '/tinyurl/*' do
  tinyurl params[:splat][0]
end

def get_url(params)
  "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}/#{URI.encode(params)}/"
end

def magick_image(image, top, bottom)
  img = Magick::Image.read(image).first

  add_text(img,top,Magick::NorthGravity)
  add_text(img,bottom,Magick::SouthGravity)

  img.format = 'jpeg'
  content_type 'image/jpeg'
  img.to_blob
end

def add_text(img, text, pos)
  tt = Magick::Draw.new
  tt.annotate(img, 0, 0, 3, 18, word_wrap(text.upcase)) do
    self.font = 'Arial'
    self.pointsize = 36
    self.font_weight = Magick::BoldWeight
    self.fill = 'white'
    self.stroke = 'black'
    self.gravity = pos
  end
end

def word_wrap(text, chars=15)
  text.gsub(/(.{1,#{chars}})(?: +|$)\n?|(.{#{chars}})/, "\\1\\2\n").chomp
end

helpers do  
  def tinyurl(url)
    open("http://tinyurl.com/api-create.php?url=#{url}").read
  end
end
__END__
@@ layout
!!! 5
%html
  %head
    %meta{:charset=>'utf-8'}
    %title= "Advice welp: " + ((text = params[:top].to_s+'/'+params[:bottom].to_s) == '/' ? "New" : text.upcase)
    %style
      body,form{width:800px;margin:auto;text-transform:uppercase;font-size:48px;font-family:Helvetica}
      img{width:400px;margin:20px 200px;}
      input{color:black;width:70%;font-size:48px;font-family:Helvetica;margin:auto;text-transform:uppercase;}
      form{margin-top:20px}
  %body
    = yield

@@ index
%form{:action=>'/',:method=>'POST'}
  %label{:for=>'top'} Top
  %input{:type=>'text',:name=>'top',:id=>'top'}
  %label{:for=>'bottom'} Bottom
  %input{:type=>'text',:name=>'bottom',:id=>'bottom'}
  %input{:type=>'submit',:value=>'MAKE'}

@@ welp
%img{:alt=>"",:src=>"/images/#{URI.escape(top)}/#{URI.escape(bottom)}"}
= tinyurl request.url
= haml :index

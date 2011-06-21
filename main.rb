%w[sinatra haml RMagick open-uri].each{|lib| require lib}

get '/' do haml :index end

post '/' do redirect "/#{params[:top]}/#{params[:bottom]}/" end

get '/:top/:bottom/' do haml :welp, :locals => params end

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
= '<div id="fb-root"></div><script src="http://connect.facebook.net/en_US/all.js#appId=208966502479582&amp;xfbml=1"></script><fb:like href="'+request.url+'" send="true" width="450" show_faces="true" font=""></fb:like>'
= '<a href="http://twitter.com/share" class="twitter-share-button" data-count="vertical" data-via="Afal" data-related="welp">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script>'
= '<div id="fb-root"></div><script src="http://connect.facebook.net/en_US/all.js#xfbml=1"></script><fb:comments href="'+request.url+'" num_posts="2" width="500"></fb:comments>'
= haml :index

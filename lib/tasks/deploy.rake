namespace :deploy do
  
  namespace :init do   
    
    task :staging do
      vars = {
      :INSTANCE_NAME=>'cafebop_staging',
      :APPLICATION_DOMAIN=>'oomlr.com',
      :GOOGLE_API_KEY=>'ABQIAAAAuTvlrqlJASuyCXRw3N66QRQMl_pjeRl5P_FnLBaAibv806AhuxSYSDfx-r5fH-hW0mXO3sDdsu2Ylw',
      :COUNTRY_CODE=>"us",
      :AMAZON_ACCESS_KEY_ID=>ENV['AMAZON_ACCESS_KEY_ID'],
      :AMAZON_SECRET_ACCESS_KEY=>ENV['AMAZON_SECRET_ACCESS_KEY'],
      :RECAPTCHA_PUBLIC_KEY=>'6LdFsQcAAAAAACX_QQwav_HmW9EyFvhcY3GgjINV',
      :RECAPTCHA_PRIVATE_KEY=>'6LdFsQcAAAAAAN2jPSftzNNhWO0uduT-0LymVTP4',
      }.to_a.map{|v| "#{v[0].to_s}='#{v[1]}'"}.join(' ')
      puts `heroku config:add #{vars} --app cafebop-staging`
    end
    
    task :prod do
      vars = {
      :INSTANCE_NAME=>'cafebop_prod',
      :APPLICATION_DOMAIN=>'cafebop.com',
      :GOOGLE_API_KEY=>'ABQIAAAAuTvlrqlJASuyCXRw3N66QRR5Z0OX2BleViBVP01ZJ4jVRbr9tBT3iT4aMGS1m6ZVZdSU-meSFacRSQ',
      :COUNTRY_CODE=>"us",
      :AMAZON_ACCESS_KEY_ID=>ENV['AMAZON_ACCESS_KEY_ID'],
      :AMAZON_SECRET_ACCESS_KEY=>ENV['AMAZON_SECRET_ACCESS_KEY'],
      :RECAPTCHA_PUBLIC_KEY=>'6LdFsQcAAAAAACX_QQwav_HmW9EyFvhcY3GgjINV',
      :RECAPTCHA_PRIVATE_KEY=>'6LdFsQcAAAAAAN2jPSftzNNhWO0uduT-0LymVTP4',
      }.to_a.map{|v| "#{v[0].to_s}='#{v[1]}'"}.join(' ')
      puts `heroku config:add #{vars} --app cafebop-prod`
    end
    
    task :au do
      vars = {
        :INSTANCE_NAME=>'cafebop_au',
        :APPLICATION_DOMAIN=>'cafebop.com.au',
        :GOOGLE_API_KEY=>'ABQIAAAAuTvlrqlJASuyCXRw3N66QRTM9r-N6Vy06GAayM_7dYsxSpKtkRQt1Q7_tPOv431HMhlsM7zqYJhqeA',
        :COUNTRY_CODE=>"au",
        :AMAZON_ACCESS_KEY_ID=>ENV['AMAZON_ACCESS_KEY_ID'],
        :AMAZON_SECRET_ACCESS_KEY=>ENV['AMAZON_SECRET_ACCESS_KEY'],
        :RECAPTCHA_PUBLIC_KEY=>'6LeWoAoAAAAAAI5kut-DpBlsJwhgu8Aj_xf-XKfo',
        :RECAPTCHA_PRIVATE_KEY=>'6LeWoAoAAAAAACTCG15ayy4BlYpHMdbvCXAskUfW'
      }.to_a.map{|v| "#{v[0].to_s}='#{v[1]}'"}.join(' ')
      puts `heroku config:add #{vars} --app cafebop-au`
    end
    
  end

  task :merge do
    `git checkout staging`
    `git merge work`
  end
                           
  task :merge_master do
    `git checkout master`
    `git merge staging`
  end
                           
  task :push_origin_staging=>[:merge] do
    `git push origin staging`
  end
  
  task :push_origin_master=>[:merge_master] do
    `git push origin master`
  end
  
  desc "Deploy to the staging Heroku environment"
  task :staging =>[:merge, :push_origin_staging] do
    `git push heroku-staging staging:master`
    `heroku rake db:migrate --app cafebop-staging`
    `git checkout work`
  end

  desc "Deploy to the production Heroku environment"
  task :prod =>[:merge_master, :push_origin_master] do
    `git push heroku-prod`
    `heroku rake db:migrate --app cafebop-prod`
    `git checkout work`
  end

  desc "Deploy to the Australian production Heroku environment"
  task :au =>[:merge_master, :push_origin_master] do
    `git push heroku-au master`
    `heroku rake db:migrate --app cafebop-au`
    `git checkout work`
  end

  

end


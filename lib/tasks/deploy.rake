namespace :deploy do
  
  namespace :init do   
    
    task :staging do
      `heroku config:add INSTANCE_NAME='cafebop_staging' --app cafebop-staging`
      `heroku config:add APPLICATION_DOMAIN='staging.cafebop.com' --app cafebop-staging`
      `heroku config:add GOOGLE_API_KEY='ABQIAAAAuTvlrqlJASuyCXRw3N66QRR5Z0OX2BleViBVP01ZJ4jVRbr9tBT3iT4aMGS1m6ZVZdSU-meSFacRSQ' --app cafebop-staging`
      `heroku config:add COUNTRY_CODE="us" --app cafebop-staging`
      `heroku config:add AMAZON_ACCESS_KEY_ID=#{ENV['AMAZON_ACCESS_KEY_ID']} --app cafebop-staging`
      `heroku config:add AMAZON_SECRET_ACCESS_KEY=#{ENV['AMAZON_SECRET_ACCESS_KEY']} --app cafebop-staging`
    end
    
    task :prod do
      `heroku config:add INSTANCE_NAME='cafebop_prod' --app cafebop-prod`
      `heroku config:add APPLICATION_DOMAIN='cafebop.com' --app cafebop-prod`
      `heroku config:add GOOGLE_API_KEY='ABQIAAAAuTvlrqlJASuyCXRw3N66QRR5Z0OX2BleViBVP01ZJ4jVRbr9tBT3iT4aMGS1m6ZVZdSU-meSFacRSQ' --app cafebop-prod`
      `heroku config:add COUNTRY_CODE="us" --app cafebop-prod`
      `heroku config:add AMAZON_ACCESS_KEY_ID=#{ENV['AMAZON_ACCESS_KEY_ID']} --app cafebop-prod`
      `heroku config:add AMAZON_SECRET_ACCESS_KEY=#{ENV['AMAZON_SECRET_ACCESS_KEY']} --app cafebop-prod`
    end
    
    task :au do
      `heroku config:add INSTANCE_NAME='cafebop_au' --app cafebop-au`
      `heroku config:add APPLICATION_DOMAIN='cafebop.com.au' --app cafebop-au`
      `heroku config:add GOOGLE_API_KEY='ABQIAAAAuTvlrqlJASuyCXRw3N66QRTM9r-N6Vy06GAayM_7dYsxSpKtkRQt1Q7_tPOv431HMhlsM7zqYJhqeA' --app cafebop-au`
      `heroku config:add COUNTRY_CODE="au" --app cafebop-au`
      `heroku config:add AMAZON_ACCESS_KEY_ID=#{ENV['AMAZON_ACCESS_KEY_ID']} --app cafebop-au`
      `heroku config:add AMAZON_SECRET_ACCESS_KEY=#{ENV['AMAZON_SECRET_ACCESS_KEY']} --app cafebop-au`
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


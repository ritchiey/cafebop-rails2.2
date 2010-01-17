namespace :deploy do

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
  task :prod =>[:merge, :push_origin_master] do
    `git push heroku-staging staging:master`
    `heroku rake db:migrate --app cafebop-prod`
    `git checkout work`
  end

  

end


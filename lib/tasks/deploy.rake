namespace :deploy do

  task :merge do
    `git checkout staging`
    `git merge work`
  end
                           
  task :push_origin_staging=>[:merge] do
    `git push origin staging`
  end
  
  desc "Deploy to the staging Heroku environment"
  task :staging =>[:merge, :push_origin_staging] do
    `git push heroku-staging staging:master`
    `heroku rake db:migrate --app cafebop-staging`
    `git checkout work`
  end



end


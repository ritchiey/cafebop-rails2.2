namespace :paypal do
  desc "Start tunnel from public IP to test machine"
  task :tunnel do
    localport = 3000
    portnum    = 5555
    puts "Invoking ssh tunnel from #{portnum} in the background"
    system "ssh -v -R '*:#{portnum}:localhost:#{localport}' ipnlink sleep 86400 &"
  end
end
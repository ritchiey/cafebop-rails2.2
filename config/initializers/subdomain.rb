def calc_tld_size
  (ENV['APPLICATION_DOMAIN'] || '.').count('.')
end

SubdomainFu.tld_size = 1 # sets for current environment
SubdomainFu.tld_sizes = {:development => 0, # localhost
                        :test => 1,
                        :cucumber=>1, 
                        :staging => calc_tld_size,
                        :production => calc_tld_size}
                        
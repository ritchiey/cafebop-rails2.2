SubdomainFu.tld_size = 1 # sets for current environment
SubdomainFu.tld_sizes = {:development => 0, # localhost
                        :test => 1,
                        :production => (ENV['APPLICATION_DOMAIN'] || '.').count('.')}
# Class/methods to load AWS profile and provide credentials
require 'parseconfig'

class Awsprofile
  def initialize(profilename)
    # Look for the files and load the profile into variables
    @config = ParseConfig.new(ENV['HOME'] + "/.aws/config")

    # Make sure we have the profile we're looking for
    if @config["profile " + profilename].nil?
      raise "Profile #{profilename} not found."
    else
      @config = @config["profile " + profilename]
    end

    # Now handle the credentials and stick them into the same @config variable
    credentials = ParseConfig.new(ENV['HOME'] + "/.aws/credentials")

    if credentials[profilename].nil?
      raise "Credentials not found for #{profilename}."
    else
      @config = @config.merge(credentials[profilename])
    end
  end

  def print
    p @config
  end
  
end

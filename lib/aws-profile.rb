# Class/methods to load AWS profile and provide credentials
require 'parseconfig'
require 'open-uri'

class Awsprofile
  def initialize(profilename)
    # Exception for using roles, this can probably be done via automatic detection
    # But this is nice and simple
    if profilename == "role"
      # Get the current region from the metadata service
      @config["region"] = open("http://169.254.169.254/latest/meta-data/placement/availability-zone").each.first(1)[0][0..-2]
    else
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
  end

  def config
    return @config
  end

end

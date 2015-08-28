#!/usr/bin/env ruby
require 'aws-sdk'
require 'yaml'
require 'getoptlong'
require './lib/aws-profile.rb'
require './lib/util.rb'

# Check args
opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--profile', '-p', GetoptLong::REQUIRED_ARGUMENT ]
)

config = ''
repetitions = 1
opts.each do |opt, arg|
  case opt
    when '--help'
      puts <<-EOF
listi [OPTION] FILTER
Where OPTIONS are:
-h, --help:
   show help

--profile aws-cli-profile-name, -p aws-cli-profile-name:
  NOTE: Use the value of "role" if you're running this on an EC2 instance and want to simply use it's role.
   Name of the AWS CLI profile you want to use (the one created by the AWS cli configure command and stored in the .aws directory in you home dir)

FILTER
  What to search for in the Name tag
      EOF
      exit 0
    when '--profile'
      @profile = arg
  end
end

if ARGV.length != 1
  puts "Missing source or destination args. Try running --help"
  exit 0
end

# Figure out credentials
credentials = Awsprofile.new(@profile)
if @profile == "role"
	# Don't pass credentials, we're using roles given to this box
	ec2 = Aws::EC2::Client.new(
		region: credentials.config["region"],
	)
else
	ec2 = Aws::EC2::Client.new(
		# Pass credentials
	  region: credentials.config["region"],
	  credentials: Aws::Credentials.new(credentials.config["aws_access_key_id"], credentials.config["aws_secret_access_key"]),
	)
end
filter = ARGV.shift

# Grab instances
resp = ec2.describe_instances({
		  dry_run: false,
		  filters: [
		  	# Make sure we only grab the instances for the environment we care about
		  	{ 	name: "tag:Name",
		    	values: [ filter ]
		    }
		  ],
})
output(resp.reservations)

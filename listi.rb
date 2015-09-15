#!/usr/bin/env ruby
require 'aws-sdk'
require 'yaml'
require 'getoptlong'
require_relative 'lib/aws-profile'
require_relative 'lib/util'

# Check args
opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--profile', '-p', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--batch', '-b', GetoptLong::NO_ARGUMENT ],
  [ '--num', '-n', GetoptLong::REQUIRED_ARGUMENT ]
)

config = ''
repetitions = 1
@outputargs = Hash.new()
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

--batch
  Batch mode, will output in comma separated format with no hostnames

FILTER
  What to search for in the Name tag
      EOF
      exit 0
    when '--profile'
      @profile = arg
    when '--batch'
      @outputargs = @outputargs.merge("batch"=>true)
    when '--num'
      @outputargs = @outputargs.merge("num"=> arg.to_i)
  end
end

if ARGV.length != 1
  puts "Missing filter arguement. Try running --help"
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
output(resp.reservations, @outputargs)

#!/usr/bin/env ruby
require 'aws-sdk'
require 'yaml'
require 'getoptlong'
require './lib/aws-profile.rb'

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

credentials = Awsprofile.new(@profile)
credentials.print
filter = ARGV.shift

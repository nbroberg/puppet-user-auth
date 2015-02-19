require "json"

ROOT_PATH = File.dirname(__FILE__)

S3_BUCKET = "<%= @credentials_bucket_name %>"
S3_BUCKET_REGION = "<%= @credentials_bucket_region %>"
PATH_TO_SSH_KEYS = "<%= @path_to_ssh_keys %>"

USER_GROUP = "admin"

TEMPORARY_SYNC_PATH = "#{ROOT_PATH}/#{Time.new.to_i}"
PUBLIC_KEY_PATH = "#{TEMPORARY_SYNC_PATH}/public_keys"
USER_MANIFESTS_PATH = "#{TEMPORARY_SYNC_PATH}/user_manifests"

ADD_USER_TEMPLATE_FILE = "#{ROOT_PATH}/update_user_template.pp"
ADD_USER_TEMPLATE = File.read(ADD_USER_TEMPLATE_FILE)

LOGGING_PATH = "/var/log/puppet/user_sync.log"

defined_users = `aws --region=#{S3_BUCKET_REGION} s3 ls s3://#{S3_BUCKET}/#{PATH_TO_SSH_KEYS}/ | awk {'print $4'} | sed -n '1!p'`.gsub('.pub','').split("\n")
current_users = `getent group #{USER_GROUP}`.strip.split(":").last.split(",")

new_users = defined_users - current_users
users_to_remove = current_users - defined_users
if new_users.empty? && users_to_remove.empty?
  puts "Current users match S3"
  exit
end

puts "Creating temporary paths for syncronization..."
Dir.mkdir(TEMPORARY_SYNC_PATH)
Dir.mkdir(PUBLIC_KEY_PATH)
Dir.mkdir(USER_MANIFESTS_PATH)

# add users
new_users.each do |username|
  puts "Downloading public key for user '#{username}'..."
  ssh_key_path = "#{PUBLIC_KEY_PATH}/#{username}.pub"
  system "aws --region=#{S3_BUCKET_REGION} s3 cp s3://#{S3_BUCKET}/#{PATH_TO_SSH_KEYS}/#{username}.pub #{ssh_key_path}"
  puts "Syncing user '#{username}'..."
  manifest_path = "#{USER_MANIFESTS_PATH}/#{username}.pp"
  ssh_key = File.read(ssh_key_path).split(" ")[1]
  manifest_content = ADD_USER_TEMPLATE.clone
  manifest_content.gsub!('$group', USER_GROUP)
  manifest_content.gsub!('$user', username)
  manifest_content.gsub!('$ssh_key', ssh_key)
  File.open(manifest_path, 'w') { |file| file.write(manifest_content) }
  system "puppet apply #{manifest_path} --debug --modulepath=/etc/puppet/modules >> #{LOGGING_PATH} 2>&1"
end

# remove users that are no longer authorized
users_to_remove.each do |user|
  puts "Removing user '#{user}'"
  system "userdel #{user}"
end

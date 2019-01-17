# puppet-user-auth

Sync SSH keys to EC2 instances using Puppet

## Requirements

- [AWS Account](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-sign-up-for-aws.html)
- Puppet 3.x
- Ruby 1.9.3-p547
- Git 2.1

## Setup

- [Grant EC2 instance access to S3](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2.html)
- [Install Puppet in Standalone mode](https://www.digitalocean.com/community/tutorials/how-to-install-puppet-in-standalone-mode-on-centos-7) on EC2 instance

## Installation

```
cd /tmp
git clone git@github.com:nbroberg/puppet-user-auth.git
cd puppet-user-auth
puppet apply manifests --debug --modulepath=/etc/puppet/modules
```

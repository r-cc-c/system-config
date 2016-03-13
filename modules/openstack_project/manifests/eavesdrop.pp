# Eavesdrop server

class openstack_project::eavesdrop (
  $nickpass = '',
  $sysadmins = [],
#  $statusbot_nick = '',
#  $statusbot_password = '',
  $statusbot_server = '',
#  $statusbot_channels = '',
#  $statusbot_auth_nicks = '',
#  $statusbot_wiki_user = '',
#  $statusbot_wiki_password = '',
#  $statusbot_wiki_url = '',
#  $statusbot_wiki_pageid = '',
  $accessbot_nick = '',
  $accessbot_password = '',
  $project_config_repo = '',
) {
  class { 'openstack_project::server':
    iptables_public_tcp_ports => [80],
    sysadmins                 => $sysadmins
  }
  include apache
  include meetbot

  $vhost_extra = '
  <Location /alert>
    Header set Access-Control-Allow-Origin "*"
  </Location>
  '

  meetbot::site { 'openswitch':
    nick        => 'openswitch',
    nickpass    => $nickpass,
    network     => 'FreeNode',
    server      => '91.217.189.42:7000',
    use_ssl     => 'True',
    vhost_extra => $vhost_extra,
    channels    => [
        '#openswitch',
    ],
  }

#  class { 'statusbot':
#    nick          => $statusbot_nick,
#    password      => $statusbot_password,
#    server        => $statusbot_server,
#    channels      => $statusbot_channels,
#    auth_nicks    => $statusbot_auth_nicks,
#    wiki_user     => $statusbot_wiki_user,
#    wiki_password => $statusbot_wiki_password,
#    wiki_url      => $statusbot_wiki_url,
#    wiki_pageid   => $statusbot_wiki_pageid,
#  }
#
#  file { '/srv/meetbot-openstack/alert':
#    ensure  => link,
#    target  => '/var/lib/statusbot/www',
#    require => Class['statusbot'],
#  }

  a2mod { 'headers':
    ensure => present,
  }

  class { 'project_config':
    url  => $project_config_repo,
  }

  class { 'accessbot':
    nick          => $accessbot_nick,
    password      => $accessbot_password,
    server        => $statusbot_server,
    channel_file  => $::project_config::accessbot_channels_yaml,
    require       => $::project_config::config_dir,
  }
}

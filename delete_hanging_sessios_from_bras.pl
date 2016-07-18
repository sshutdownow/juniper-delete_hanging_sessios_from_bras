#!/usr/bin/perl -w
use strict;
#
# $$ script to kill hanging sessions from brases
#
use Sys::Syslog qw/:standard :macros/;
use Net::Telnet;
use POSIX ":sys_wait_h";

use vars qw/%brases $user_password $enable_password/;

BEGIN {
    openlog('delete_hanging_sessios_from_bras', 'nofatal,pid', LOG_LOCAL7);
    $SIG{__DIE__} = sub {
     syslog(LOG_ERR, @_);
     CORE::die @_;
     return 1;
    };

    $SIG{__WARN__} = sub {
     syslog(LOG_WARNING, @_);
     return 1;
    };
}

END {
    syslog LOG_INFO, 'exit';
    closelog();
}


my $DEBUG = 1;

%brases = ('BRAS1' => '192.168.128.101', 'BRAS2' => '192.168.128.102', 'BRAS3' => '192.168.128.103');

$user_password = shift || 'password';
$enable_password = shift || 'enable password';

umask 0077; # to make telnet dump readable only for owner

foreach my $bras (keys %brases) {
    my $t_session = new Net::Telnet(-Timeout => 10,
                                -output_record_separator => "\r",
                                -Dump_Log => "/var/log/delete-hanging-sessions-${bras}.log"
                                );

    $t_session->errmode('return');
    syslog(LOG_DEBUG, "open session on $bras");
    $t_session->open($brases{$bras});
    syslog(LOG_DEBUG, "try to auth on $bras");

    $t_session->waitfor('/Telnet password:.*$/');
    if ($t_session->timed_out) {
        warn "auth timed out on $bras" if $DEBUG;
        next;
    }
    $t_session->print($user_password);

    syslog(LOG_DEBUG, "try to enable on $bras");
    $t_session->cmd('enable');
    $t_session->waitfor('/Password:.*$/');
    if ($t_session->timed_out) {
        warn "enable timed out on $bras" if $DEBUG;
        next;
    }
    $t_session->print($enable_password);

    $t_session->prompt('/#\s?$/');

    $t_session->cmd('terminal width 500');
    $t_session->cmd('terminal length 0');
    syslog(LOG_DEBUG, "try to get list of hanging sesssions on $bras");
    my @sessions = $t_session->cmd(String => 'show service-management subscriber-session brief | include Delete', Timeout => 180);
    $t_session->prompt('/(config)#\s?$/');
    $t_session->cmd('configure terminal');
    foreach my $session (@sessions) {
        if ($session =~ m/(\d+)\s+AAA\s\d+\s+Delete/) {
            syslog(LOG_DEBUG, "try to kill session [$1] on $bras: ", $t_session->cmd("no service-management subscriber-session $1 force") );
        }
    }

    syslog(LOG_DEBUG, "close session on $bras");
    $t_session->close();
}

exit 0;

#!/usr/bin/perl

use strict;
use warnings;

my $env_vars = {
    RUN_TESTS_AND_EXIT => 'yes',
    SYNC_REPO     => $ENV{SYNC_REPO} || '.',
    LOCAL_USER_ID => qx{id -u},
    COVERAGE      => $ENV{COVERAGE},
    KOHA_IMAGE    => $ENV{KOHA_IMAGE} || 'master',
    KTD_BRANCH    => $ENV{KTD_BRANCH} || 'master',
    TEST_SUITE    => $ENV{TEST_SUITE} // 'full',
    DBMS_YML      => $ENV{DBMS_YML} || '',
    ES_YML        => $ENV{ES_YML} || '',
};
while ( my ( $var, $value ) = each %$env_vars ) {
    $ENV{$var} = $value;
}

my @docker_compose_yml;

# Cleanup
run(q{rm -rf cover_db});
run(q{git clean -f});

my $GITLAB_RAW_URL = "https://gitlab.com/koha-community/koha-testing-docker/raw/" . $ENV{KTD_BRANCH};

if ( $ENV{TEST_SUITE} eq 'light' ) {
    push @docker_compose_yml, 'docker-compose-light.yml';
} else {
    push @docker_compose_yml, 'docker-compose.yml';
}

if ( $ENV{DBMS_YML} ) {
    push @docker_compose_yml, $ENV{DBMS_YML};
} else {
    if (      $ENV{KOHA_IMAGE} =~ m|stretch| ) {
        push @docker_compose_yml, 'docker-compose.mariadb_d9.yml';
    } elsif ( $ENV{KOHA_IMAGE} =~ m|buster| ) {
        push @docker_compose_yml, 'docker-compose.mariadb_d10.yml';
    } elsif ( $ENV{KOHA_IMAGE} =~ m|bullseye| || $ENV{KOHA_IMAGE} eq 'master' ) {
        push @docker_compose_yml, 'docker-compose.mariadb_d11.yml';
    } elsif ( $ENV{KOHA_IMAGE} =~ m|bookworm| ) {
        push @docker_compose_yml, 'docker-compose.mariadb_d12.yml';
    } elsif ( $ENV{KOHA_IMAGE} =~ m|bionic| ) {
        push @docker_compose_yml, 'docker-compose.mariadb_u18.yml';
    } elsif ( $ENV{KOHA_IMAGE} =~ m|focal| ) {
        push @docker_compose_yml, 'docker-compose.mariadb_u20.yml';
    } elsif ( $ENV{KOHA_IMAGE} =~ m|jammy| ) {
        push @docker_compose_yml, 'docker-compose.mariadb_u22.yml';
    } elsif ( $ENV{KOHA_IMAGE} =~ m|sid| ) {
        push @docker_compose_yml, 'docker-compose.mariadb_latest.yml';
    }
}

if ( $ENV{ES_YML} ) {
    push @docker_compose_yml, $ENV{ES_YML};
}

for my $yml ( @docker_compose_yml ) {
    run(qq{wget -O $yml $GITLAB_RAW_URL/$yml}, { exit_on_error => 1 });
}

my $docker_compose_env = "$GITLAB_RAW_URL/env/defaults.env";
run(qq{wget -O .env $docker_compose_env}, { exit_on_error => 1 });

docker_cleanup();

my $cmd = 'docker-compose ' . join( ' ', map { "-f $_" } @docker_compose_yml ) . ' pull --quiet';
run($cmd, { exit_on_error => 1 });

# Run tests
$cmd =
    'docker-compose '
  . join( ' ', map { "-f $_" } @docker_compose_yml )
  . ' -p koha up --abort-on-container-exit --no-color --force-recreate';
run($cmd, { exit_on_error => 1, use_pipe => 1 });

# Post cleanup
docker_cleanup();

run(qq{rm $_}) for @docker_compose_yml;
run(q{rm -rf .env});

sub run {
    my ( $cmd, $params ) = @_;
    my $exit_on_error = $params->{exit_on_error};
    my $use_pipe      = $params->{use_pipe};
    if ( $use_pipe ) {
        $cmd .= " 2>&1";
        my $fh;
        if ( $exit_on_error ) {
            open($fh, '-|', $cmd) or die "Failed to execute: $cmd ($!)";
        } else {
            open($fh, '-|', $cmd);
            if ($!) { warn "Failed to execute: $cmd ($!)"; return; }
        }
        while (my $line = <$fh>) { print $line }
    } else {
        if ( $exit_on_error ) {
            print qx{$cmd} . "\n" or die "Failed to execute $cmd";
        } else {
            print qx{$cmd} . "\n";
        }
    }
}

sub docker_cleanup {
    run(q{docker-compose -p koha down});

    my $containers = qx{docker ps -a -f "name=koha_xx" -q};
    chomp $containers;
    if ( $containers ) {
        run(qq{docker stop \$(docker ps -a -f "name=koha_" -q)});
        run(qq{docker rm \$(docker ps -a -f "name=koha_" -q)});
    }

    run(q{docker volume prune -f});
    run(q{docker image  prune -f});
    run(q{docker system prune -a -f});
}

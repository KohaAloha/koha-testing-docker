#!/usr/bin/perl

use Modern::Perl;

my $env_vars = {
    RUN_TESTS_AND_EXIT => 'yes',
    SYNC_REPO     => $ENV{SYNC_REPO} || '.',
    LOCAL_USER_ID => qx{id -u},
    COVERAGE      => $ENV{COVERAGE},
    KOHA_IMAGE    => $ENV{KOHA_IMAGE} || 'master',
    KTD_BRANCH    => $ENV{KTD_BRANCH} || 'master',
    LIGHT_RUN     => $ENV{LIGHT_RUN} // 1,
    DBMS_YML      => $ENV{DBMS_YML} || '',
};
while ( my ( $var, $value ) = each %$env_vars ) {
    $ENV{$var} = $value;
}

my @docker_compose_yml;

# Cleanup
run(q{rm -rf cover_db});
run(q{git clean -f});

my $GITLAB_RAW_URL = "https://gitlab.com/koha-community/koha-testing-docker/raw/" . $ENV{KTD_BRANCH};

if ( $ENV{LIGHT_RUN} == 1 ) {
    push @docker_compose_yml, 'docker-compose-light.yml';
} else {
    push @docker_compose_yml, 'docker-compose.yml';
}

if ( $ENV{DBMS_YML} ) {
    push @docker_compose_yml, $ENV{DBMS_YML};
}

for my $yml ( @docker_compose_yml ) {
    run(qq{wget -O $yml $GITLAB_RAW_URL/$yml}, 'or die');
}

my $docker_compose_env = "$GITLAB_RAW_URL/env/defaults.env";
run(qq{wget -O .env $docker_compose_env}, 'or die');

run(q{docker system prune -a -f});
my $cmd = 'docker-compose ' . join( ' ', map { "-f $_" } @docker_compose_yml ) . ' pull';
run($cmd, 'or die');

# Run tests
$cmd =
    'docker-compose '
  . join( ' ', map { "-f $_" } @docker_compose_yml )
  . ' -p koha up --abort-on-container-exit --no-color --force-recreate';
run($cmd, 'or die');

# Post cleanup
run(q{docker-compose down});
run(qq{docker rm \$(docker ps -a -f "name=koha_" -q)});
run(q{docker volume prune -f});
run(q{docker image  prune -f});
run(q{docker system prune -a -f});

run(qq{rm $_}) for @docker_compose_yml;
run(q{rm -rf .env});

sub run {
    my ( $cmd, $exit_on_error ) = @_;
    $cmd .= " 2>&1";
    my $fh;
    if ( $exit_on_error ) {
        open($fh, '-|', $cmd) or die "Failed to execute: $cmd ($!)";
    } else {
        open($fh, '-|', $cmd);
        if ($!) { warn "Failed to execute: $cmd ($!)"; return; }
    }
    while (my $line = <$fh>) { print $line }
}

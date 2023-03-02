#!/bin/bash

set -e

figlet a2

# Stop apache2
service apache2 status
service apache2 stop
service apache2 status
service apache2 start
service apache2 status

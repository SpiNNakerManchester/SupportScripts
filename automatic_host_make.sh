# This script assumes it is run from the directory holding all github projects in parallel
# sh SupportScripts/automatic_host_make.sh

set -e

make -f SupportScripts/automatic-host.mk

echo "completed host binary compilation"

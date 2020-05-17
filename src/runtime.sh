#!/bin/sh

# This is verbatim from the example at 
# https://docs.aws.amazon.com/lambda/latest/dg/runtimes-walkthrough.html
# except I'm annotating things for my own edification


# I've seen set -e but never this
# okay -- went down a rabbit hole with set -- for starters, I found out you can 
# inspect functions defined in your bash session just with 
# $ set
# these options mean
# -e exit on non zero exit status of sub commands (basically)
# -u treat undefined variables as errors in parameter expansion
# -o pipefail -- set the pipefail option to true, meaning:
#     the return value of a pipeline is the last 
#     command to exit with a nonzero status
set -euo pipefail

# looks like we're just sourcing our handler function
# $LAMBDA_TASK_ROOT must be like, the working dir of our lambda env
source $LAMBDA_TASK_ROOT/"$(echo $_HANDLER | cut -d. -f1).sh"

# seems to be the main event loop

while true
do 
    # make a temporary file and store it's path in HEADERS
    HEADERS="$(mktemp)"

    # okay, this is pretty interesting... it looks like we're making a blocking request
    # to some server, maybe a local server, that's hosting the lambda runtime api
    # and basically longpolling for the next event
    EVENT_DATA=$(curl -sS \
        -LD "$HEADERS" \
        -X GET "http://${AWS_LAMBDA_RUNTIME_API}/2018-06-01/runtime/invocation/next")
    # TODO . . . 

done
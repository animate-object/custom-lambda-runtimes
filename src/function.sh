
# So this is their pretty simple little lambda handler sample
# It logs the event to stderr and echoes it back to the caller
# If you tossed jq into your runtime environment though, it looks like
# you could have a nice simple bash script that handles structured data
# lot of power here (although for most use cases I think I'd pick something
# a little more formal, like python)
function handler() {
    EVENT_DATA=$1
    echo "$EVENT_DATA" 1>&2;
    RESPONSE="Echoing request: '$EVENT_DATA'"

    echo $RESPONSE
}
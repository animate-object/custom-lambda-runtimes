deps() {
    command -v jq &> /dev/null || (echo "this script requires jq" && exit 1)
    command -v aws &> /dev/null || (echo "this script requires awscli" && exit 1)
}


ROLE_NAME='CustomRuntimeDemoLambdaRole'

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"


find_or_create_lambda_role() {
    echo "checking for lambda role"

    local found_role=$(aws iam list-roles | jq ".Roles[] | select(.RoleName==\"$ROLE_NAME\")")
    if [ -z "$found_role" ]
    then
        echo "creating role"
        role=$(aws iam create-role \
            --role-name "$ROLE_NAME" \
            --assume-role-policy-document "file://$DIR/lambda-policy.json")
        aws iam attach-role-policy \
            --role-name $ROLE_NAME \
            --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
        role_arn=$(echo $role)
    else
        role_arn=$(echo $found_role | jq -r .Arn)
        echo "found role $ROLE_NAME with arn $role_arn"
    fi

    echo $role_arn
}




deps
find_or_create_lambda_role
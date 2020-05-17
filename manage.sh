
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# config, feel free to edit these
ROLE_NAME='CustomRuntimeDemoLambdaRole'
FUNCTION_NAME="custom-runtime-demo"
FUNCTION_BUNDLE="$DIR/function.zip"


deps() {
    command -v jq &> /dev/null || (echo "this script requires jq" && exit 1)
    command -v aws &> /dev/null || (echo "this script requires awscli" && exit 1)
}



find_or_create_lambda_role() {
    local found_role=$(aws iam list-roles | jq ".Roles[] | select(.RoleName==\"$ROLE_NAME\")")
    if [ -z "$found_role" ]
    then
        role=$(aws iam create-role \
            --role-name "$ROLE_NAME" \
            --assume-role-policy-document "file://$DIR/lambda-policy.json")
        aws iam attach-role-policy \
            --role-name $ROLE_NAME \
            --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
        role_arn=$(echo $role)
    else
        role_arn=$(echo $found_role | jq -r .Arn)
    fi

    echo $role_arn
}

package() {
    rm $FUNCTION_BUNDLE
    pushd $DIR/src
    zip $FUNCTION_BUNDLE *
    chmod 755 *
    popd
}


create_fn() {
    local role_arn=$1
    echo $role_arn
    # I bet --handler sets the value of $_HANDLER
    aws lambda create-function --function-name $FUNCTION_NAME \
        --zip-file "fileb://$FUNCTION_BUNDLE" --handler "function.handler" \
        --runtime provided --role $role_arn
}

fn_exists() {
    return $(aws lambda get-function --function-name $FUNCTION_NAME &> /dev/null && 1) || 0
}

new_fn() {
    ROLE_ARN=$(find_or_create_lambda_role)

    if ! fn_exists
    then
        package
        create_fn $ROLE_ARN
        rm $FUNCTION_BUNDLE
    else
        echo "function $FUNCTION_NAME already exists"
    fi    
}

delete_fn() {
    aws lambda delete-function --function $FUNCTION_NAME
}
delete_role() {
    echo 'unimplemented'
}

update_fn() {
    echo 'unimplimented'
}


main() {
    local command=$1

    case "$command" in
        create)
            new_fn
            ;;
        update)
            update_fn
            ;;
        delete)
            delete_fn
            delete_role
            ;;
        *)
            echo "Invalide option: $command"
            echo "Usage: $0 [create|update|delete]"
            exit 1
    esac
}

deps
main $1
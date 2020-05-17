# Working through the [custom runtimes tutorial](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-walkthrough.html)

## Goals:

- Learn enough about custom runtimes to package a Deno runtime
- Minimal pointy-click config, prefer scriptable/infra as code solutions
- Document the process for future generations

It looks like this tutorial is a guide for making a bash runtime -- that's pretty interesting. Seems like there are some interesting use cases for executing bash scripts on demand/remotely (nightly data processing, anyone?)

One of the first things this guide directs you to do is to create a lambda execution role through the console. Let's see if we can figure out how to do it in the cli

```
aws iam create-role --generate-cli-skeleton
{
    "Path": "",
    "RoleName": "",
    "AssumeRolePolicyDocument": ""
}

```

huh, `--generate-cli-skeleton` is cool.

Okay, I'm going to go ahead and borrow the policy document their example suggests, AWSLambdaBasicExecutionRole. It looks like it basically allows writing to cloudwatch logs. Seems reasonable.

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
```

I'm going to put this in a file called `lambda-policy.json`

Started writing a script called bootstrap.sh -- this will be an idempotent way to create the infrastructure required for this project. Executing it requires some admin privileges in your ecosystem. I'm going with a scripting solution here because cloudformation feels a little heavy for this project at the moment.

Bootstrap.sh now looks for a role called `CustomRuntimeDemoLambdaRole` and creates it with the right permissions if it does not exist.

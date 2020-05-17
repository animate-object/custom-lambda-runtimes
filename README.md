# Working through the AWS Lambda [custom runtimes tutorial](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-walkthrough.html)

## Goals:

- Learn enough about custom runtimes to package a Deno runtime -- I found [this one](https://github.com/hayd/deno-lambda), but I figured I'd like to understand what's going on a bit better.
- Minimal pointy-click config, prefer scriptable/infra as code solutions
- Document the process for future generations

It looks like this tutorial is a guide for making a bash runtime -- that's pretty interesting. Seems like there are some interesting use cases for executing bash scripts on demand/remotely (nightly data processing, anyone?)

One of the first things this guide directs you to do is to create a lambda execution role through the console. Let's see if we can figure out how to do it in the cli

I've started writing a script called bootstrap.sh -- this will be an idempotent way to create the infrastructure required for this project. Executing it requires some admin privileges in your ecosystem. I'm going with a scripting solution here because cloudformation feels a little heavy for this project at the moment.

Bootstrap.sh now looks for a role called `CustomRuntimeDemoLambdaRole` and creates it with the right permissions if it does not exist.

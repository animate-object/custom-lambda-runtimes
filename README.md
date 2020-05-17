# Working through the AWS Lambda [custom runtimes tutorial](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-walkthrough.html)

## Goals:

- Learn enough about custom runtimes to package a Deno runtime -- I found [this one](https://github.com/hayd/deno-lambda), but I figured I'd like to understand what's going on a bit better.
- Minimal pointy-click config, prefer scriptable/infra as code solutions
- Document the process for future generations

It looks like this tutorial is a guide for making a bash runtime -- that's pretty interesting. Seems like there are some interesting use cases for executing bash scripts on demand/remotely (nightly data processing, anyone?)

~
One of the first things this guide directs you to do is to create a lambda execution role through the console. Let's see if we can figure out how to do it in the cli

~
I've started writing a script called bootstrap.sh -- this will be an idempotent way to create the infrastructure required for this project. Executing it requires some admin privileges in your ecosystem. I'm going with a scripting solution here because cloudformation feels a little heavy for this project at the moment.

~
Bootstrap.sh now looks for a role called `CustomRuntimeDemoLambdaRole` and creates it with the right permissions if it does not exist.

~
Okay, so I'm starting to dive into the sort of 'pseudo runtime' that they have you build in the first pass and I came across the amazon lambda runtime interface.

It is pretty cool, from what I can tell, amazon-lambda-runtime-interface is a process that runs locally in the lambda execution environment and allows you to create an event loop. Your lambda basically polls it for incoming events, and then pushes responses back. All over http via what's basically a restful API. Neat.

~
Picking up where we left off, I've copied the rest of the code and annotated it. We have a simple little runtime that initializes our environment and feeds incoming requests to our handler in a simple event loop. It then it posts the handlers response back to the lambda runtime.

The docs note that this simple example doesn't handle _all_ runtime responsibilities, in particular it doesn't make use of the AWS lambda runtime interface's error handling capabilities.

~
Now it looks like we're going to package this up and deploy it. I'm going to modify my bootstrap.sh script to create the function if it doesn't exist. I think I'd also like it to _update_ the function if it does exist, so I can play with the code.

~
Okay, I worked through a couple issues on start up -- one, it looks like if you're not using layers, lambda looks for an executable called boostrap in /var/task or /opt that it invokes on startup. So I renamed `src/runtime` to `src/boostrap`. This is what the guide suggested initially, but now the significance of the naming is clear.

To alleviate confusion, I renamed my infrastructure management script from `bootstrap.sh` to `manage.sh`. I also updated it to accept commands to create, update, and delete the function, so you can test this code and remove it easily.

Everything seems to be working, we have a custom bash runtime that calls a simple 'echoing' handler.

The next step in the tutorial is to upgrade this to use layers.

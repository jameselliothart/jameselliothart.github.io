title: MediatR vs Discriminated Unions
date: 10-24-20
author: James Hart
category: Development
tags: MediatR, .NET, C#, F#, Patterns, FunctionalProgramming

In this post, I will compare and contrast what the [MediatR](https://github.com/jbogard/MediatR) makes possible in C# with what we can achieve natively in F# with [discriminated unions](https://docs.microsoft.com/en-us/dotnet/fsharp/language-reference/discriminated-unions).
This is not meant to be an exhaustive review of the features and capabilities of MediatR or what is possible with functional techniques, just some musings on the advantages or differences between them.

The MediatR library is a [mediator pattern](https://en.wikipedia.org/wiki/Mediator_pattern) implementation which allows us to dispatch commands via [generics](https://docs.microsoft.com/en-us/dotnet/csharp/programming-guide/generics/) variance.
In F#, we can achieve a similar result by defining a discriminated union comprising the commands or actions to which the application can respond and a handler function which dispatches to other functions based on that command.

Both of these techniques allow us to decouple business logic from infrastructure concerns such as parsing and validating incoming requests at the application boundary.
As we will see, this can greatly increase both the testability and extensibility of the app.
Our example will show this for a web API project.

However, this decoupling can be obfuscating as it becomes harder to follow the logical flow of the program.
We will see that discriminated unions offer an advantage here by giving us more visibility into the behavior of the application at compile time.

Full source code is available [here](https://github.com/jameselliothart/MediatrVsDU).

## MediatR

First we'll explore the MediatR side.
We create the project and add the necessary nuget packages:

```shell
$ mkdir MediatrVsDU
$ cd MediatrVsDU
$ dotnet new sln
$ dotnet new webapi -n ExampleMediatR
$ dotnet sln add ExampleMediatR/ExampleMediatR.fsproj
$ cd ExampleMediatR
$ dotnet add package MediatR
$ dotnet add package MediatR.Extensions.Microsoft.DependencyInjection
```

Then add MediatR to the configured services:

```csharp
using MediatR;
// ...
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddControllers();
            services.AddMediatR(typeof(Startup));
        }
```

Now we can define the first query which MediatR will handle.
Under `Controllers`, create `WeatherQuery.cs` and `WeatherQueryHandler.cs` with definitions below.

```csharp
// WeatherQuery.cs
using MediatR;
namespace ExampleMediatR.Controllers
{
    public class WeatherQuery : IRequest<WeatherForecast>
    {
        public string Day { get; set; }
    }
}
```

```csharp
// WeatherQueryHandler.cs
using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;

namespace ExampleMediatR.Controllers
{
    public class WeatherQueryHandler : IRequestHandler<WeatherQuery, WeatherForecast>
    {
        public Task<WeatherForecast> Handle(WeatherQuery request, CancellationToken cancellationToken)
        {
            var rng = new Random();
            var weather = new WeatherForecast
            {
                Date = DateTime.Now,
                TemperatureC = rng.Next(-20,55),
                Summary = $"Weather for {request.Day}"
            };
            return Task.FromResult(weather);
        }
    }
}
```

The `IRequest` and `IRequestHandler` interfaces come from MediatR and are how the library knows how to route commands.
In this case, when MediatR receives a `WeatherQuery`, it will look for a class which implements `IRequestHandler<WeatherQuery, WeatherForecast>` - corresponding to the `WeatherQuery` type and the expected response type `WeatherForecast` configured for `WeatherQuery`.

Now update `WeatherForecastController` like the below:

```csharp
using MediatR;
// ...
    [ApiController]
    [Route("[controller]")]
    public class WeatherForecastController : ControllerBase
    {
        private readonly IMediator mediator;

        public WeatherForecastController(IMediator mediator)
        {
            this.mediator = mediator;
        }

        [HttpGet("{day}")]
        public async Task<IActionResult> Get(string day)
        {
            var query = new WeatherQuery { Day = day };
            WeatherForecast result = await mediator.Send(query);
            return Ok(result);
        }
    }
```

Note the `[Route("[controller]")]` attribute sets the route to the name of the class minus "Controller" - so `/WeatherForecast` in this case.
As an aside, you may want to avoid this tight coupling between the outer facing contract (the url route) and the internal class name, but I have left it consistent with the standard project template.

If we run the project and navigate to <https://localhost:5001/WeatherForecast/today>, we should get a response like the below:

```json
{
    "date":"2020-10-24T10:10:35.1037149-05:00",
    "temperatureC":23,
    "temperatureF":73,
    "summary":"Weather for today"
}
```

This setup allows the controller to be responsible only for creating the `WeatherQuery` from the incoming request and returning the result - all the "heavy lifting" is done by the single line `WeatherForecast result = await mediator.Send(query);`.
Of course, there is little "heavy lifting" in this simple example, but imagine that the `WeatherQueryHandler` had some complicated logic, e.g. retrieving records from a database or other service, processing them, and saving back to a database.

Being able to test and change that logic in isolation from the HTTP request concerns of the controller is a great benefit.
I first saw this technique demonstrated in [vkhorikov's](https://github.com/vkhorikov) [Pluralsight Course](https://www.pluralsight.com/courses/cqrs-in-practice) (source code [here](https://github.com/vkhorikov/CqrsInPractice)) and found it very useful in my projects to be able to unit test the logic of my applications without having to worry about the web server and HTTP concerns.

However, it is difficult to trace which handler is actually doing the work as MediatR dispatches in the background using reflection.
We help with this a little by explicitly typing `WeatherForecast result` as the use of `var` would almost completely obfuscate the behavior.
The real problem though is that we have no guarantee that a handler is actually implemented at all!

To see an example of this, define `BadQuery` as below:

```csharp
// BadQuery.cs
using MediatR;
namespace ExampleMediatR.Controllers
{
    public class BadQuery : IRequest<string>
    {
        public string Day { get; set; }
        public string Bad { get; set; }
    }
}
```

Then add a route in the `WeatherForecastController`:

```csharp
        [HttpGet("{day}/{bad}")]
        public async Task<IActionResult> BadGet(string day, string bad)
        {
            var query = new BadQuery { Day = day, Bad = bad };
            string result = await mediator.Send(query);
            return Ok(result);
        }
```

If we run the project and navigate to <https://localhost:5001/WeatherForecast/today/bad>, we get a nasty runtime exception:

>fail: Microsoft.AspNetCore.Diagnostics.DeveloperExceptionPageMiddleware[1]
>      An unhandled exception has occurred while executing the request.
>System.InvalidOperationException: Handler was not found for request of type MediatR.IRequestHandler`2[ExampleMediatR.Controllers.BadQuery,System.String]. Register your handlers with the container. See the samples in GitHub for examples.

We would need integration tests of the API itself to catch this behavior which is something we were trying to avoid in the first place.
As the project grows, it could also be difficult to find which handler responds to particular requests (though naming conventions can help with this).

Are these simply trade-offs we have to accept?
In the next section, we will see how we can get the same benefits while mitigating the drawbacks.

## Discriminated Unions

Back at the root of our solution, we run the following commands to set up the F# project:

```shell
$ dotnet new webapi -lang F# -n ExampleDU
$ cd ExampleDU
```

Add `Weather.fs` and define it as below.
Note the `[<AutoOpen>]` attribute allows us to access the types and functions defined in the `Weather` module as soon as we open the `ExampleDU` namespace without having to qualify them.

```fsharp
namespace ExampleDU

open System
open System.Threading.Tasks

[<AutoOpen>]
module Weather =

    type Query =
    | Weather of day: string

    let mediator = function
        | Weather d ->
            let rng = Random()
            {
                Date = DateTime.Now;
                TemperatureC = rng.Next(-20,55);
                Summary = sprintf "Weather for %s" d
            } |> Task.FromResult
```

Here we have defined the `Query` discriminated union (of the single `Weather` case for now - we will add to this later) and a `mediator` function which implicitly takes the `Query` type and dispatches behavior based on the case.
For simplicity, the handler logic is within the `mediator` function itself, but we could easily define a `weatherHandler` function for the `mediator` to call.
This is essentially the equivalent of the `WeatherQuery` and `WeatherQueryHandler` we defined before.
Already this is less code and requires no additional packages.

Now update the `WeatherForecastController` as below:

```fsharp
[<ApiController>]
[<Route("[controller]")>]
type WeatherForecastController () =
    inherit ControllerBase()

    [<HttpGet("{day}")>]
    member this.Get(day) =
        Weather day |> mediator |> this.Ok
```

This too is simpler since we no longer need to inject the mediator, and we can naturally compose a pipeline.
Running the application and navigating to <https://localhost:5001/WeatherForecast/today>, the response is familiar:

```json
{
    "result":{
        "date":"2020-10-24T11:13:49.6887379-05:00",
        "temperatureC":1,
        "summary":"Weather for today",
        "temperatureF":33
        },
    "id":1,
    "exception":null,
    "status":5,
    "isCanceled":false,
    "isCompleted":true,
    "isCompletedSuccessfully":true,
    "creationOptions":0,
    "asyncState":null,
    "isFaulted":false
}
```

Let's see what happens when we fail to handle a query as before.
Update the `Query` type with a `Bad` case and add a route in the controller:

```fsharp
// Weather.fs
    type Query =
    | Weather of day: string
    | Bad of day: string * bad: string
```

```fsharp
// WeatherForecastController.fs
    [<HttpGet("{day}/{bad}")>]
    member this.BadGet(day, bad) =
        Bad (day, bad) |> mediator |> this.Ok
```

Now both in the editor and when we build the project, we get a helpful warning like the below:

>/home/james/source/repos/MediatrVsDU/ExampleDU/Weather.fs(13,20): warning FS0025: Incomplete pattern matches on this expression. For example, the value `'Bad >(_, _)' may indicate a case not covered by the pattern(s). [/home/james/source/repos/MediatrVsDU/ExampleDU/ExampleDU.fsproj]
>
>    1 Warning(s)
>
>    0 Error(s)

Since F# is able to check at compile time that all cases of a discriminated union are accounted for, it is very easy to tell what we missed and where to fix it.
Not only that, but having a defined `mediator` function allows us to quickly identify how a particular request is handled rather than having to rely on naming conventions or looking at type signatures.

Of course, if we ignore this warning and run the application anyway, navigating to <https://localhost:5001/WeatherForecast/today/bad> will produce a runtime error as before:

>fail: Microsoft.AspNetCore.Diagnostics.DeveloperExceptionPageMiddleware[1]
>      An unhandled exception has occurred while executing the request.
>Microsoft.FSharp.Core.MatchFailureException: The match cases were incomplete

## Conclusion

In this post, we saw two different techniques within the .NET ecosystem of isolating business logic from infrastructure concerns such as HTTP requests and responses and briefly discussed the benefits of doing so.
In the C# world, the MediatR library accomplishes this with a little setup but can leave us open to surprises at runtime and obfuscate the logical flow of our application.
We then saw that we can mitigate these issues in F# by leveraging discriminated unions to get better compile time feedback.

Of course, if you are already using one language for a particular project, you will likely not be able to switch to the other.
Still, I hope this information can help to inform the language choice on your next project (which may not be far away if you have a [microservice](https://microservices.io/) architecture) or give ideas about how to leverage this pattern within an existing .NET project.

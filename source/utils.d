import requests : Response;
import std.json : parseJSON, JSONValue;
import std.stdio : writeln;

bool isSuccessful(Response response)
{
    return 200 <= response.code && response.code < 300;
}

void prettyPrint(Response response)
{
    response.jsonBody.toPrettyString().writeln();
}

JSONValue jsonBody(Response response)
{
    //doesn't work : return cast(string)(response.responseBody).parseJSON();
    //works : return (cast(string)(response.responseBody)).parseJSON();
    return parseJSON(cast(string) response.responseBody);
}


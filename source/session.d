import config;
import std.stdio : writeln;
import std.file : readText;
import std.string : format, strip, lineSplitter;
import std.conv : to;
import std.array : join;
import std.json : parseJSON, JSONValue;
import requests : Request, Response;
import utils : prettyPrint, isSuccessful, jsonBody;

void login(string username, string password)
{
    auto request = createSession(username, password);
    auto response = request.send();
    if(!response.isSuccessful || "errors" in response.jsonBody)
    {
        writeln("Login failed");
        response.prettyPrint();
        return;
    }
    string token = response.jsonBody["data"].object["createSession"].object["token"].str;
    config.put("token", token);
}

void logout()
{
    config.put("token", "");
}

struct GraphQLRequest
{
    string operationName;
    string query;
    JSONValue variables;

    JSONValue toJson()
    {
        return JSONValue([
            "operationName": JSONValue(operationName),
            "variables": variables,
            "query": JSONValue(query),
        ]);
    }

    string toString()
    {
        return toJson().toPrettyString();
    }

    Response send()
    {
        return Request().post(config.get("endpoint"), toString(), "application/json");
    }
}

GraphQLRequest createSession(string username, string password)
{
    enum query = import("createSession.graphql").lineSplitter().join("\n");
    auto variables = SessionPayload(username, password).toJson();
    return GraphQLRequest("createSession", query, variables);
}

struct SessionPayload
{
    string email;
    string password;

    //todo : make this a template mixin or something
    JSONValue toJson()
    {
        return JSONValue([
            "email": JSONValue(email),
            "password": JSONValue(password)
        ]);
    }

    string toString()
    {
        return toJson().toPrettyString();
    }
}

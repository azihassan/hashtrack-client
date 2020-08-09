import std.stdio : writeln;
import std.file : readText;
import std.string : format, strip, lineSplitter;
import std.conv : to;
import std.array : join;
import std.json : parseJSON, JSONValue;
import std.algorithm : each;
import std.stdio : writeln;

import requests : Request, Response;
import utils : prettyPrint, isSuccessful, jsonBody, errors, throwOnFailure;
import graphql : GraphQLRequest;
import config : Config;

struct Session
{
    Config configuration;

    this(Config configuration)
    {
        this.configuration = configuration;
    }

    void login(string username, string password)
    {
        auto request = createSession(username, password);
        auto response = request.send();
        response.throwOnFailure();
        string token = response.jsonBody["data"].object["createSession"].object["token"].str;
        configuration.put("token", token);
    }

    void logout()
    {
        configuration.put("token", "");
    }

    User status()
    {
        auto request = currentUser();
        auto response = request.send();
        response.throwOnFailure();
        auto content = response.jsonBody["data"].object["currentUser"].object;
        return User(
                content["id"].str,
                content["name"].str,
                content["email"].str
                );
    }

    GraphQLRequest createSession(string username, string password)
    {
        enum query = import("createSession.graphql").lineSplitter().join("\n");
        auto variables = SessionPayload(username, password).toJson();
        return GraphQLRequest("createSession", query, variables, configuration);
    }

    GraphQLRequest currentUser()
    {
        enum query = import("currentUser.graphql").lineSplitter().join("\n");
        auto variables = JSONValue();
        return GraphQLRequest("currentUser", query, variables, configuration);
    }
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

struct User
{
    string id;
    string name;
    string email;

    JSONValue toJson()
    {
        return JSONValue([
            "id": JSONValue(id),
            "name": JSONValue(name),
            "email": JSONValue(email)
        ]);
    }

    string toString()
    {
        return toJson().toPrettyString();
    }
}

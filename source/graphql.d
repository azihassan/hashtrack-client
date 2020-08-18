module graphql;

import std.json : JSONValue;
import requests : Response, Request;
import config : Config;

struct GraphQLRequest
{
    string operationName;
    string query;
    JSONValue variables;
    Config configuration;

    JSONValue toJson() const
    {
        return JSONValue([
            "operationName": JSONValue(operationName),
            "variables": variables,
            "query": JSONValue(query),
        ]);
    }

    string toString() const
    {
        return toJson().toPrettyString();
    }

    Response send() const
    {
        auto request = Request();
        request.addHeaders(["Authorization": configuration.get("token", "")]);
        return request.post(configuration.get("endpoint"), toString(), "application/json");
    }
}

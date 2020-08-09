import std.json : JSONValue;
import requests : Request, Response;
import config : Config;

struct GraphQLRequest
{
    string operationName;
    string query;
    JSONValue variables;
    Config config;

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
        auto request = Request();
        request.addHeaders(["Authorization": config.get("token", "")]);
        return request.post(config.get("endpoint"), toString(), "application/json");
    }
}

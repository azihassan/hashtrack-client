import std.json : JSONValue;
import config;
import requests : Request, Response;

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
        auto request = Request();
        request.addHeaders(["Authorization": config.get("token", "")]);
        return request.post(config.get("endpoint"), toString(), "application/json");
    }
}

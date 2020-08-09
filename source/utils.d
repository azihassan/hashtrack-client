import requests : Response, RequestException;
import std.json : parseJSON, JSONValue;
import std.stdio : writeln;
import std.string : join;

bool isSuccessful(Response response)
{
    return 200 <= response.code && response.code < 300;
}

string[] errors(Response response)
{
    return response.jsonBody.errors;
}
string[] errors(JSONValue jsonBody)
{
    string[] result;
    if("errors" !in jsonBody)
    {
        return result;
    }

    foreach(error; jsonBody["errors"].array)
    {
        if("message" in error)
        {
            result ~= error["message"].str;
        }
    }
    return result;
}

unittest
{
    string response = q{{
    "data": null,
    "errors": [
        {
            "extensions": {
                "code": "INTERNAL_SERVER_ERROR",
            },
            "locations": [
                {
                    "column": 5,
                    "line": 2
                }
            ],
            "message": "Could not find any entity of type \"Track\" matching: {\n    \"userId\": \"77ca5575-465b-43cd-b259-1f36da7b5245\",\n    \"hashtagName\": \"php\"\n}",
            "path": [
                "removeTrack"
            ]
        },
        {
            "extensions": {
                "code": "INTERNAL_SERVER_ERROR",
            }
        }
    ]
}};
    assert(response.parseJSON().errors == ["Could not find any entity of type \"Track\" matching: {\n    \"userId\": \"77ca5575-465b-43cd-b259-1f36da7b5245\",\n    \"hashtagName\": \"php\"\n}"]);
    assert(`{"data": "Data inserted successfully"}`.parseJSON().errors == []);
    assert(`{}`.parseJSON().errors == []);
}

void prettyPrint(Response response)
{
    response.toPrettyString().writeln();
}

string toPrettyString(Response response)
{
    return response.jsonBody.toPrettyString();
}

JSONValue jsonBody(Response response)
{
    //doesn't work : return cast(string)(response.responseBody).parseJSON();
    //works : return (cast(string)(response.responseBody)).parseJSON();
    return parseJSON(cast(string) response.responseBody);
}


void throwOnFailure(Response response)
{
    if(!response.isSuccessful || "errors" in response.jsonBody)
    {
        string[] errors = response.errors;
        throw new RequestException(errors.join("\n"));
    }
}


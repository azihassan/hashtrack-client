import std.stdio : writeln;
import std.algorithm : map;
import std.string : lineSplitter, startsWith;
import std.json : JSONValue;
import std.array : join;
import config;
import utils : isSuccessful, toPrettyString, jsonBody, errors;
import graphql : GraphQLRequest;

string[][string] track(string[] hashtags)
{
    string[][string] failures;
    foreach(hashtag; hashtags.map!prependHash)
    {
        auto request = createTrack(hashtag);
        auto response = request.send();
        if(!response.isSuccessful || "errors" in response.jsonBody)
        {
            failures[hashtag] = response.errors;
        }
    }
    return failures;
}

string[][string] untrack(string[] hashtags)
{
    string[][string] failures;
    foreach(hashtag; hashtags.map!prependHash)
    {
        auto request = removeTrack(hashtag);
        auto response = request.send();
        if(!response.isSuccessful || "errors" in response.jsonBody)
        {
            failures[hashtag] = response.errors;
        }
    }
    return failures;
}

string[] tracks()
{
    auto response = getTracks().send();
    string[] hashtags;
    if(!response.isSuccessful || "errors" in response.jsonBody)
    {
        response.errors.writeln;
        return hashtags;
    }

    foreach(hashtag; response.jsonBody["data"].object["tracks"].array)
    {
        hashtags ~= hashtag["prettyName"].str;
    }
    return hashtags;
}

GraphQLRequest createTrack(string hashtag)
{
    enum query = import("createTrack.graphql").lineSplitter().join("\n");
    auto variables = JSONValue([
        "name": hashtag
    ]);
    return GraphQLRequest("createTrack", query, variables);
}

GraphQLRequest removeTrack(string hashtag)
{
    enum query = import("removeTrack.graphql").lineSplitter().join("\n");
    auto variables = JSONValue([
        "name": hashtag
    ]);
    return GraphQLRequest("removeTrack", query, variables);
}

GraphQLRequest getTracks()
{
    enum query = import("tracks.graphql").lineSplitter().join("\n");
    auto variables = JSONValue();
    return GraphQLRequest("tracks", query, variables);
}

string prependHash(string hashtag)
{
    if(hashtag.startsWith('#'))
    {
        return hashtag;
    }
    return '#' ~ hashtag;
}

unittest
{
    assert("dlang".prependHash() == "#dlang");
    assert("#dlang".prependHash() == "#dlang");
    assert("".prependHash() == "#");
    assert("#".prependHash() == "#");
}

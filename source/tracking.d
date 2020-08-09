import std.stdio : writeln;
import std.algorithm : map;
import std.string : lineSplitter, startsWith, format, wrap, replace;
import std.json : JSONValue;
import std.array : join;
import config;
import utils : isSuccessful, toPrettyString, jsonBody, errors, throwOnFailure;
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

Tweet[] list(string search = "")
{
    Tweet[] tweets;
    auto request = getTweets(search);
    auto response = request.send();
    response.throwOnFailure();

    foreach(tweet; response.jsonBody["data"].object["tweets"].array)
    {
        tweets ~= Tweet(
            tweet["id"].str,
            tweet["authorName"].str,
            tweet["text"].str,
            tweet["publishedAt"].str
        );
    }
    return tweets;
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

GraphQLRequest getTweets(string search = "")
{
    enum query = import("tweets.graphql").lineSplitter().join("\n");
    auto variables = JSONValue(["search": search]);
    return GraphQLRequest("tweets", query, variables);
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

struct Tweet
{
    string id;
    string authorName;
    string text;
    string publishedAt;

    string url() @property
    {
        return format!`https://twitter.com/%s/status/%s`(
            authorName.replace("@", ""),
            id
        );
    }

    string toString()
    {
        return format!"%s (%s)\n%s\n%s\n"(
            authorName,
            publishedAt,
            text.wrap(60),
            url
        );
    }
}

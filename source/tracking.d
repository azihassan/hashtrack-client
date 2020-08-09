import std.stdio : writeln;
import std.algorithm : map;
import std.string : lineSplitter, startsWith, format, wrap, replace;
import std.json : JSONValue;
import std.array : join;

import utils : isSuccessful, toPrettyString, jsonBody, errors, throwOnFailure;
import graphql : GraphQLRequest;
import config : Config;

struct Tracking
{
    Config configuration;

    this(Config configuration)
    {
        this.configuration = configuration;
    }

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

    private GraphQLRequest createTrack(string hashtag)
    {
        enum query = import("createTrack.graphql").lineSplitter().join("\n");
        auto variables = JSONValue([
                "name": hashtag
        ]);
        return GraphQLRequest("createTrack", query, variables, configuration);
    }

    private GraphQLRequest removeTrack(string hashtag)
    {
        enum query = import("removeTrack.graphql").lineSplitter().join("\n");
        auto variables = JSONValue([
                "name": hashtag
        ]);
        return GraphQLRequest("removeTrack", query, variables, configuration);
    }

    private GraphQLRequest getTracks()
    {
        enum query = import("tracks.graphql").lineSplitter().join("\n");
        auto variables = JSONValue();
        return GraphQLRequest("tracks", query, variables, configuration);
    }

    private GraphQLRequest getTweets(string search = "")
    {
        enum query = import("tweets.graphql").lineSplitter().join("\n");
        auto variables = JSONValue(["search": search]);
        return GraphQLRequest("tweets", query, variables, configuration);
    }
}

string prependHash(string hashtag)
{
    return hashtag.startsWith('#') ? hashtag : '#' ~ hashtag;
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

unittest
{
    auto tweet = Tweet("ID", "Hassan", "This is a test", "XXX");
    assert(tweet.url == "https://twitter.com/Hassan/status/ID");

    tweet = Tweet("ID", "@Hassan", "This is a test", "XXX");
    assert(tweet.url == "https://twitter.com/Hassan/status/ID");
}

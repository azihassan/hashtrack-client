import std.stdio : writeln, write, readln;
import std.string : strip;
import std.algorithm : joiner, each;
import std.path : expandTilde;
import std.getopt;

import session : Session;
import tracking : Tracking;
import config : Config;

void main(string[] args)
{
    bool login;
    bool logout;
    string[] track;
    string[] untrack;
    bool tracks;
    bool list;
    bool watch;
    bool status;
    string endpoint;
    string configPath = expandTilde("~/.config/hashtrack/config.json");

    //weird
    arraySep = ",";
    //accidently reversed the order of the args
    auto opts = args.getopt(
        "login", "Creates a session token and store it in the local filesystem in a config file", &login,
        "logout", "Remove the locally stored session token", &logout,
        "track", "Tracks one or more hashtags", &track,
        "untrack", "Untracks one or more previously tracked hashtags", &untrack,
        "tracks", "Displays the hashtags you are tracking", &tracks,
        "list", "Displays the latest 50 captured tweets", &list,
        "watch", "Stream and display the captured tweets in real-time", &watch,
        "status", "Displays who you are, if logged in", &status,
        "endpoint", "Point to another server", &endpoint,
        "config", "Load a custom config file", &configPath
    );

    //how to handle "no arguments were passed"
    if(opts.helpWanted)
    {
        defaultGetoptPrinter("Usage of the hashtrack client :", opts.options);
        return;
    }

    auto configuration = Config(configPath, endpoint);

    if(login)
    {
        write("Username : ");
        string username = readln.strip;

        write("Password : ");
        string password = readln.strip;
        Session(configuration).login(username, password);
    }

    if(logout)
    {
        Session(configuration).logout();
    }

    if(track.length > 0)
    {
        auto failures = Tracking(configuration).track(track);
        if(failures.length > 0)
        {
            writeln("The following hashtags could not be tracked");
            foreach(k, v; failures)
            {
                writeln(k);
                writeln("Cause:");
                writeln(v.joiner("\n"));
                writeln();
            }
        }
    }

    if(untrack.length > 0)
    {
        auto failures = Tracking(configuration).untrack(untrack);
        if(failures.length > 0)
        {
            writeln("The following hashtags could not be untracked");
            foreach(k, v; failures)
            {
                writeln(k);
                writeln("Cause:");
                writeln(v.joiner("\n"));
                writeln();
            }
        }
    }

    if(tracks)
    {
        Tracking(configuration).tracks.each!writeln;
    }

    if(list)
    {
        string filter = args.length > 1 ? args[1] : "";
        Tracking(configuration).list.each!writeln;
    }

    if(status)
    {
        Session(configuration).status.writeln;
    }
}

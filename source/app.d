import std.stdio : writeln, write, readln;
import std.string : strip;
import std.getopt;
import session;
import config : createConfigFile;

void main(string[] args)
{
    createConfigFile();
    bool login;
    bool logout;
    string[] track;
    string[] untrack;
    bool tracks;
    bool list;
    bool watch;
    bool status;
    string endpoint;
    string config;

    //weird
    arraySep = ",";


    //accidently reversed the order of the args
    auto opts = args.getopt(
        std.getopt.config.passThrough,
        "login", "Creates a session token and store it in the local filesystem in a config file", &login,
        "logout", "Remove the locally stored session token", &logout,
        "track", "Tracks one or more hashtags", &track,
        "untrack", "Untracks one or more previously tracked hashtags", &untrack,
        "tracks", "Displays the hashtags you are tracking", &tracks,
        "list", "Displays the latest 50 captured tweets", &list,
        "watch", "Stream and display the captured tweets in real-time", &watch,
        "status", "Displays who you are, if logged in", &status,
        "endpoint", "Point to another server", &endpoint,
        "config", "Load a custom config file", &config
    );

    //how to handle "no arguments were passed"
    if(opts.helpWanted)
    {
        defaultGetoptPrinter("Usage of the hashtrack client :", opts.options);
        return;
    }


    if(login)
    {
        write("Username : ");
        string username = readln.strip;

        write("Password : ");
        string password = readln.strip;
        session.login(username, password);
    }

    if(logout)
    {
        session.logout();
    }
}

module getpass;

version(linux)
{
    //https://news.ycombinator.com/item?id=24222188
    import core.sys.linux.unistd : getpass;
    import std.conv : to;
    import std.string : toStringz;
    string getpass(string prompt)
    {
        return getpass(prompt.toStringz()).to!string;
    }
}
else
{
    import std.stdio : readln, write;
    string getpass(string prompt)
    {
        prompt.write();
        return readln();
    }
}
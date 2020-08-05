import std.stdio : writeln;
import config;

void login(string username, string password)
{
    writeln("Logging in with ", username, ", ", password);
    config.put("token", "foobar");
}

void logout()
{
    config.put("token", "");
}

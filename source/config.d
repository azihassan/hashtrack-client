import std.stdio : writeln;
import std.path : expandTilde, dirName;
import std.file : exists, write, mkdirRecurse, readText;
import std.json;

string config() @property
{
    return expandTilde("~/.config/hashtrack/config.json");
}

void createConfigFile()
{
    if(!config.exists)
    {
        mkdirRecurse(config.dirName);
        config.write("{}");
    }
}

void put(string key, string value)
{
    JSONValue json = config.readText.parseJSON;
    json.object[key].str = value;
    config.write(json.toPrettyString());
}

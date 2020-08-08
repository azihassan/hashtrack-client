import std.stdio : writeln;
import std.path : expandTilde, dirName;
import std.file : exists, write, mkdirRecurse, readText;
import std.json : JSONValue, parseJSON;

string config() @property
{
    return expandTilde("~/.config/hashtrack/config.json");
}

void createConfigFile()
{
    if(!config.exists)
    {
        mkdirRecurse(config.dirName);
        config.write(q{{
            "endpoint": "https://hashtrack.herokuapp.com/graphql"
        }});
    }
}

void put(string key, string value)
{
    JSONValue json = config.readText.parseJSON;
    json.object[key] = JSONValue(value);
    config.write(json.toPrettyString());
}

string get(string key, string defaultValue = "")
{
    JSONValue json = config.readText.parseJSON;
    if(key in json)
    {
        return json[key].str;
    }
    return defaultValue;
}

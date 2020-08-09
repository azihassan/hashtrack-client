import std.stdio : writeln;
import std.path : dirName;
import std.file : exists, write, mkdirRecurse, readText;
import std.json : JSONValue, parseJSON;

struct Config
{
    string path;
    string endpoint;

    this(string path, string endpoint = "")
    {
        this.path = path;
        this.endpoint = endpoint;
        createConfigFile();
    }

    void createConfigFile()
    {
        if(!path.exists)
        {
            mkdirRecurse(path.dirName);
            path.write(q{{
                "endpoint": "https://hashtrack.herokuapp.com/graphql"
            }});
        }
    }

    void put(string key, string value)
    {
        JSONValue json = path.readText.parseJSON;
        json.object[key] = JSONValue(value);
        path.write(json.toPrettyString());
    }

    string get(string key)
    {
        string value = get(key, null);
        if(value == null)
        {
            throw new Exception("key " ~ key ~ " was not found in the config file");
        }
        return value;
    }

    string get(string key, string defaultValue)
    {
        if(key == "endpoint" && endpoint != "")
        {
            return endpoint;
        }
        JSONValue json = path.readText.parseJSON;
        if(key in json)
        {
            return json[key].str;
        }
        return defaultValue;
    }
}

unittest
{
    auto config = Config("/tmp/config.json");
    assert(config.get("endpoint") == "https://hashtrack.herokuapp.com/graphql");

    config = Config("/tmp/config.json", "");
    assert(config.get("endpoint") == "https://hashtrack.herokuapp.com/graphql");

    config = Config("/tmp/config.json", "another endpoint");
    assert(config.get("endpoint") == "another endpoint");

    config.put("foo", "bar");
    assert(config.get("foo") == "bar");

    assert(config.get("XXX", "default") == "default");

    import std.exception : assertThrown;
    assertThrown(config.get("XXX"));
}

import std.path : expandTilde, dirName;
import std.file : exists, write, mkdirRecurse;

string config() @property
{
    return expandTilde("~/.config/hashtrack/config.json");
}

void createConfigFile()
{
    if(!config.exists)
    {
        mkdirRecurse(config.dirName);
        config.write("");
    }
}

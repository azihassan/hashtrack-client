module term;

import std.string : format;

string bold(string input)
{
    return input.format!"\u001b[1m%s\u001b[0m";
}

string cyan(string input)
{
    return input.format!"\u001b[36;1m%s\u001b[0m";
}

string dimmed(string input)
{
    return input.format!"\u001b[34;1m%s\u001b[0m";
}

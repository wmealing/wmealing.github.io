#!/usr/bin/env escript

-include_lib("kernel/include/file.hrl").

main(_) ->
    %% 1. Find all .org files and sort by creation/modification time
    Files = filelib:wildcard("*.org"),
    
    %% Get file info for each and sort descending (newest first)
    FileInfoList = lists:map(fun(F) -> {F, file_info(F)} end, Files),
    Sorted = lists:sort(fun({_, A}, {_, B}) -> A#file_info.mtime > B#file_info.mtime end, FileInfoList),
    
    %% 2. Take the last 25 (the most recent ones)
    RecentFiles = lists:sublist(Sorted, 25),
    
    %% 3. Extract metadata from each file
    Items = lists:map(fun({Filename, _}) -> extract_metadata(Filename) end, RecentFiles),
    
    %% 4. Generate and write the RSS
    RSS = generate_rss(Items),
    file:write_file("rss.xml", RSS),
    io:format("Generated rss.xml with ~p items.~n", [length(Items)]).

file_info(Filename) ->
    {ok, Info} = file:read_file_info(Filename),
    Info.

extract_metadata(Filename) ->
    {ok, Content} = file:read_file(Filename),
    
    %% Extract Title: #+TITLE: Some Title
    Title = case re:run(Content, "^#\\+TITLE:\\s*(.*)$", [multiline, {capture, [1], list}]) of
        {match, [T]} -> T;
        nomatch -> Filename
    end,
    
    %% Extract Description: content="..."
    Desc = case re:run(Content, "content=\"([^\"]*)\"", [{capture, [1], list}]) of
        {match, [D]} -> D;
        nomatch -> ""
    end,
    
    %% Construct Link: filename.org -> filename.html
    Link = filename:rootname(Filename) ++ ".html",
    
    {Title, Link, Desc}.

generate_rss(Items) ->
    Header = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n"
             "<rss version=\"2.0\">\n"
             "<channel>\n"
             "<title>Wade Mealing - Erlang | Infosec | Human</title>\n"
             "<link>http://wmealing.github.io</link>\n"
             "<description>RSS generated via Erlang</description>\n",
    Footer = "</channel>\n</rss>",
    ItemXML = lists:map(fun item_to_xml/1, Items),
    iolist_to_binary([Header, ItemXML, Footer]).

item_to_xml({Title, Link, Desc}) ->
    io_lib:format(
        "<item>\n"
        "<title>~s</title>\n"
        "<link>https://wmealing.github.io/~s</link>\n"
        "<description>~s</description>\n"
        "</item>\n", [Title, Link, Desc]).

#nodemon --watch lib --watch test -e ex,exs --exec "clear && mix test"
#/disks/1TB/C_Driver/rods/Documents/LINQPad Queries/Rename-Movies.linq

defmodule Renmovies do
    import Print

  def main(args \\[]) do
    # IO.inspect parse_args(args)

    IO.inspect write_load_config()
  end

  def print_usage do
    import IO.ANSI
    format([
            :italic,
            "Path:\t ",
            color(8), File.cwd!, "\n",
            color(25), :bright, :not_italic,
            "\nUsage:\n\n",
            color(7),
            "\trenmovie delete       : to delete unnecessary files\n",
            "\trenmovie rename       : to rename files and folders\n",
            "\trenmovie extract      : to extract content from subfolders\n",
            "\trenmovie --dry-run    : to simulate what will happen"
    ], true)
  end

  def parse_args(args) do
    option = OptionParser.parse(args, strict: [dry_run: :boolean])

    p = &(IO.puts/1)

    case option do
        {_, _, [{_, nil}]}
            -> p.(print_usage())
            :wrong
        {[dry_run: true], ["rename"], _}
            -> :dry_rename
        {[dry_run: true], ["extract"], _}
            -> extract(true)
            :dry_extract
        {[dry_run: true], ["delete"], _}
            -> delete(true)
            :dry_delete
        {_, ["rename"], _}
            -> :do_rename
        {_, ["extract"], _}
            -> extract(false)
            :do_extract
        {_, ["delete"], _}
            -> delete(true)
            :do_delete
        _
            -> p.(print_usage())
            :show_print
    end
  end

  defp write_load_config() do
    {:ok, path} = File.cwd
    user_directory = Regex.named_captures(~r/(?<user>\/home\/\w+\/)/, path)["user"]
    config_file = user_directory <> ".config/renmovies.json"

    file = File.read(config_file)

    case file do
      { :ok, content } -> file_to_json(content)
      { :error, _ } -> json_to_file(config_file) |> file_to_json()
    end
  end

  defp json_to_file(config_file) do
    config = Poison.encode!(%ConfigFile{
      undo: "true", 
      delete_size_st: "20mb",
      rename_pattern: [%{
        # TODO: just for tests, DESCONTOPOM WILL ROCK
        regx: "(\\D+)(\\d+)(\\D+)", 
        repl: "\\1 <-> \\3"
      }]
    }, pretty: true)

    File.write(config_file, config, [:binary])
    File.read!(config_file)
  end

  defp file_to_json(content) do
    config = Poison.decode!(content, as: %ConfigFile{})
        
    patterns = config.rename_pattern 
      |> Enum.filter_map(fn x -> 
        regex = Regex.compile x["regx"]
        case regex do
          {:ok, r} -> true
          {:error, e} ->
            IO.puts "[#{x["regx"]}] is an invalid Regex"
            false
        end
      end, fn x -> 
        # IO.inspect x
        regex = Regex.compile! x["regx"]
        Map.update(x, "regx", ~r//, & &1 = regex)
      end)
      # |> IO.inspect

    Map.update(config, :rename_pattern, %{}, & &1 = patterns)
  end

  def extract(dry \\true) do
    Extract.extract_files(dry)
  end

  def delete(dry \\true) do
    
  end
end

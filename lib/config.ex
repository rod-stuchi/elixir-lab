defmodule Config do
  
  def write_load_config() do
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
      undo_changes: "true", 
      extensions_keep: ["mov", "mp4", "avi", "mkv"],
      extensions_delete: ["txt", "rar", "7z", "zip"],
      rename_patterns: [%Patterns{
          input: "aaaaaaaa12341324124bbbbbbb",
          output: "",
          regex: "(\\D+)(\\d+)(\\D+)", 
          replace: "\\1 <-> \\3"
        }]
    }, pretty: true)

    File.write(config_file, config, [:binary])
    File.read!(config_file)
  end

  defp file_to_json(content) do
    config = Poison.decode!(content, as: %ConfigFile{})
        
    patterns = config.rename_patterns 
      |> Enum.filter_map(fn x -> 
        regex = Regex.compile x["regex"]
        case regex do
          {:ok, r} -> true
          {:error, e} ->
            IO.puts "[#{x["regex"]}] is an invalid Regex"
            false
        end
      end, fn x -> 
        # IO.inspect x
        regex = Regex.compile! x["regex"]
        out = Regex.replace(regex, x["input"], x["replace"])
        x = Map.update(x, "output", "", & &1 = out) 
        x = Map.update(x, "regex", ~r//, & &1 = regex)
      end)
      # |> IO.inspect

    Map.update(config, :rename_patterns, %{}, & &1 = patterns)
  end
end
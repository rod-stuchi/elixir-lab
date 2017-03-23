defmodule Utils do
  
  #------------------------------------------------------------------------------------------------------------------
  def write_load_config() do
    {:ok, path} = File.cwd
    user_directory = Regex.named_captures(~r/(?<user>\/home\/\w+\/)/, path)["user"]
    config_file = user_directory <> ".config/renafiles.json"

    file = File.read(config_file)

    case file do
      { :ok, content } -> file_to_json(content)
      { :error, _ } -> json_to_file(config_file) |> file_to_json()
    end
  end

  #------------------------------------------------------------------------------------------------------------------
  def save_state(state_file) do
    log_state = [%Model.LogState{
        unix_datetime: DateTime.utc_now |> DateTime.to_unix(:microsecond),
        state_file: state_file
    }]

    undo_renfiles = Path.join(File.cwd!, ".renafiles.bin")

    if File.exists?(undo_renfiles) do
      file_state = File.read!(undo_renfiles) |> :erlang.binary_to_term

      prev_now_state = file_state ++ log_state
      File.write! undo_renfiles, :erlang.term_to_binary(prev_now_state)
      {:ok, length(prev_now_state)}
    else
      File.write! undo_renfiles, :erlang.term_to_binary(log_state)
      {:ok, 1}
    end
  end

  #------------------------------------------------------------------------------------------------------------------
  def get_paths() do
    fsize = fn p ->
      case File.stat p do
        {:ok, %{size: sizee}} -> Sizeable.filesize(sizee)
        {:error, reason} -> reason
      end
    end

    # TODO: remove /movies/
    path = File.cwd! <> "/movies/*"

    Path.wildcard(path)
    |> Enum.filter(fn f -> File.dir?(f) end)
    |> Enum.map(fn fl -> %Model.StateFile{
      basedir: Path.relative_to_cwd(fl),
      paths: Path.wildcard(fl <> "/**")
      |> Enum.filter_map(
          fn fd -> not File.dir?(fd) end,
          fn sp -> %Model.Paths{
            old: Path.relative_to_cwd(sp),
            new: Path.join(fl, Path.basename(sp)) |> Path.relative_to_cwd(),
            size: fsize.(sp),
            hash: case Utils.hash_file(sp) do
              {:ok, h} -> h
              {:error, _} -> ""
            end
      } end)
      |> Enum.filter(fn f -> f.old != f.new end)
    } end)
    |> Enum.map(fn x ->
      newpaths =
      x.paths
      |> Enum.group_by(& &1.new)
      |> Enum.map(fn {_, x} ->
        cond do
          Enum.count(x) > 1 ->
            Enum.with_index(x, 1)
            |> Enum.map(fn x ->
              {u, index} = x
              Map.update(u, :new, "",
                &(String.replace(&1, ~r{.([^.]+$)}, "#{String.pad_leading(Integer.to_string(index), 2, "0")}.\\1"))
              )
            end)
          Enum.count(x) <= 1 ->
            x
        end
      end)
      |> List.flatten()
      Map.update(x, :paths, [], &(&1 = newpaths))
    end)
  end


  #==================================================================================================================
  defp json_to_file(config_file) do
    config = Poison.encode!( %Model.Config{
      undo_changes: "true", 
      extensions_keep: ["mov", "mp4", "avi", "mkv"],
      extensions_delete: ["txt", "rar", "7z", "zip"],
      rename_patterns: [%Model.Patterns{
          input: "aaaaaaaa12341324124bbbbbbb",
          output: "",
          regex: "(\\D+)(\\d+)(\\D+)", 
          replace: "\\1 <-> \\3"
        }]
      }, pretty: true)

    File.write(config_file, config, [:binary])
    File.read!(config_file)
  end

  #==================================================================================================================
  defp file_to_json(content) do
    config = Poison.decode!(content, as: %Model.Config{
      rename_patterns: [%Model.Patterns{}]
    })
        
    patterns = config.rename_patterns 
      |> Enum.filter_map(fn x -> 
        regex = Regex.compile x.regex
        case regex do
          {:ok, _} -> true
          {:error, _} ->
            IO.puts "[#{x["regex"]}] is an invalid Regex"
            false
        end
      end, fn x -> 
        regex = Regex.compile! x.regex
        out = Regex.replace(regex, x.input, x.replace)
        x = Map.update(x, :output, "", & &1 = out) 
        Map.update(x, :regex, ~r//, & &1 = regex)
      end)

    Map.update(config, :rename_patterns, %{}, & &1 = patterns)
  end

  #==================================================================================================================
  def hash_file(path) do
    hashFile = System.cmd("sha1sum", [path])

    case hashFile do
      {hasha, 0} ->
        [h1|_] = Regex.run(~r{[[:xdigit:]]+}, hasha)
        {:ok, h1}

      {_, 1} -> 
        {:error, "Invalid path"}
    end
  end

  #==================================================================================================================
  # defp hash(data, protocol) do
  #   :crypto.hash(protocol, data) |> Base.encode64
  # end
end
defmodule Extract do
    import Print

#------------------------------------------------------------------------------------------------------------------
  def extract_files(dry \\true) do
    paths = get_paths()

    print_result = fn dry ->
      import IO.ANSI
      IO.puts format([
        color(2), :bright,
        dry
          && "\n dry-run, will extract files to base directory:\n\n"
          || "\n extracted files to base directory:\n\n",
        Enum.map(paths, fn d -> [
          color(7),
          " " <> d.basedir, :italic,
          "\n   from: \n",
          color(8), :normal, :not_italic,
          Enum.map(d.paths, fn x -> "     │ " <> Path.relative_to(x.old, d.basedir) <> "\n" end),
          color(7), :italic,
          "   to:\n",
          color(7), :normal, :not_italic,
          Enum.map(d.paths, fn x -> "     ║ " <> Path.relative_to(x.new, d.basedir) <> "\n" end),
          "\n",
        ] end)
      ], true)
    end

    if (dry) do
      print_result.(dry)

      print save_state paths
    else
      # move files
      paths
      |> Enum.map(fn x ->
        x.paths |> Enum.map(fn p ->
          File.rename(p.old, p.new)
        end)
      end)

      # remove empty directories
      paths
      |> Enum.map(fn x ->
        Path.wildcard(x.basedir <> "/**")
        |> Enum.filter_map(& File.dir?(&1), & File.rm_rf(&1))
      end)

      print_result.(dry)
    end
  end

#------------------------------------------------------------------------------------------------------------------
  defp save_state(paths) do
    log_state = [%Model.LogState{
        unix_datetime: DateTime.utc_now |> DateTime.to_unix(:microsecond),
        state_file: paths
    }]
    state_json = Poison.encode!(log_state, pretty: true)
    undo_renfiles = Path.join(File.cwd!, ".undo_renfiles")

    if File.exists?(undo_renfiles) do
      content_state_json = File.read!(undo_renfiles)

      content_state = Poison.decode!(content_state_json,
        as: [%Model.LogState{
          state_file: [%Model.StateFile{
            paths: [%Model.Paths{}]
          }]
        }]
      )

      prev_now_state = content_state ++ log_state
      new_state_json = Poison.encode!(prev_now_state, pretty: true)

      File.write(undo_renfiles, new_state_json, [:binary])
      {:ok, length(prev_now_state)}
    else
      File.write(undo_renfiles, state_json, [:binary])
      {:ok, 1}
    end
  end

#------------------------------------------------------------------------------------------------------------------
  defp get_paths() do
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
end
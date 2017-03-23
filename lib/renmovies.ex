#nodemon --watch lib --watch test -e ex,exs --exec "clear && mix test"
#/disks/1TB/C_Driver/rods/Documents/LINQPad Queries/Rename-Movies.linq

defmodule Renmovies do
  import Print

  def main(args \\[]) do
    IO.inspect parse_args(args)
    # IO.inspect Utils.write_load_config()
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
      "\trenmovie undo         : to undo all the changes (not apply to removed files)\n",
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
      {[dry_run: true], ["undo"], _}
        -> undo(true)
          :dry_undo
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

  def extract(dry \\true) do
    Extract.extract_files(dry)
  end

  def delete(dry \\true) do

  end

  def undo(dry \\true) do
    IO.puts dry
  end
end

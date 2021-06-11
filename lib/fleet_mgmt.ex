defmodule FleetMgmt do
  alias FleetMgmt.{Coupon, Package, Shipment}

  def main(args) do
    # Define Coupons
    coupons = readFile(args) |> Coupon.get_coupons()

    # Read BaseValue and Number of Packages
    [sBaseVal, sPkgs] =
      IO.gets("")
      |> String.split([" ", "\n"], trim: true)

    {baseVal, _} = Integer.parse(sBaseVal)
    {pkgs, _} = Integer.parse(sPkgs)

    # Read all Package information and fleet information
    input = read(pkgs + 1)
    if length(input) == pkgs + 1 do
      do_problem2(input, pkgs, coupons, baseVal)
    else
      do_problem1(input, pkgs, coupons, baseVal)
    end
  end

  def do_problem2(input, pkgs, coupons, baseVal) do
    fleet_dtl = input |> Enum.reverse() |> hd() |> String.split([" ", "\n"], trim: true)

    # Calculate total, discount and time taken
    input
    |> Enum.take(pkgs)
    |> Package.parse_package(coupons, baseVal)
    |> Shipment.get_time_taken(fleet_dtl)
    |> format_output(2)
  end

  def do_problem1(input, pkgs, coupons, baseVal) do
    # Calculate total, discount
    input
    |> Enum.take(pkgs)
    |> Package.parse_package(coupons, baseVal)
    |> format_output(1)
  end


  def format_output(out_val, x) do
    out_val
    |> Enum.map(fn pkg ->
      out = case x do
        1 -> pkg.packageID <>
          " " <>
          Package.format_val(pkg.discount) <>
          " " <> Package.format_val(pkg.total_cost - pkg.discount)
        2 -> pkg.packageID <>
          " " <>
          Package.format_val(pkg.discount) <>
          " " <> Package.format_val(pkg.total_cost - pkg.discount) <> " " <> Package.format_val(pkg.time)
      end
      IO.puts(out)

      out
    end)
  end

  # This method is used to parse the coupons stored in JSON file
  defp readFile(args) do
    options = [switches: [coupons: :string], aliases: [c: :coupons]]
    {opts, _, _} = OptionParser.parse(args, options)

    File.read!(opts[:coupons])
  end

  # To read the data line by line until an empty line is read from console
  defp read(n),
    do: IO.stream(:stdio, :line) |> Stream.take_while(&(&1 != "\n")) |> Enum.take(n + 1)
end

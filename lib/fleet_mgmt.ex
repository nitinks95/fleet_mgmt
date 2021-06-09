defmodule FleetMgmt do

  alias FleetMgmt.{Coupon, Package, Shipment}

  def main(args) do
    # Define Coupons
    coupons = readFile(args) |> Coupon.get_coupons()

    # Read BaseValue and Number of Packages
    [sBaseVal, sPkgs] = IO.gets("")
    |> String.split([" ", "\n"], trim: true)
    {baseVal, _ } = Integer.parse(sBaseVal)
    {pkgs, _ } = Integer.parse(sPkgs)

    # Read all Package information and fleet information
    input = read(pkgs+1)
    fleet_dtl = input |> Enum.reverse() |> hd() |> String.split([" ", "\n"], trim: true)

    # Calculate total, discount and time taken
    input
    |> Enum.take(pkgs)
    |> Package.parse_package(coupons, baseVal)
    |> Shipment.get_time_taken(fleet_dtl)
    |> Package.format_output()
  end

  defp readFile(args) do
    options = [switches: [coupons: :string],aliases: [c: :coupons]]
    {opts,_,_}= OptionParser.parse(args, options)

    File.read!(opts[:coupons])
  end

  defp read(n), do: IO.stream(:stdio, :line) |> Stream.take_while(& &1 != "\n") |> Enum.take(n+1)

end

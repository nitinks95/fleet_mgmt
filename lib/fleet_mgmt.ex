defmodule FleetMgmt do

  alias FleetMgmt.{Coupon}

  def main(args) do
    # Define Coupons
    _coupons = readFile(args) |> Coupon.get_coupons()
  end

  defp readFile(args) do
    options = [switches: [coupons: :string],aliases: [c: :coupons]]
    {opts,_,_}= OptionParser.parse(args, options)

    File.read!(opts[:coupons])
  end

end

defmodule FleetMgmt.Package do

  alias FleetMgmt.{Coupon}

  @enforce_keys [:packageID, :distance, :weight]
  defstruct packageID: "", distance: nil, weight: nil, total_cost: nil, discount: nil, time: nil

  def format_output(out_val) do
    out_val
    |> Enum.map(fn pkg ->
      out = pkg.packageID <> " " <> format_val(pkg.discount) <> " " <> format_val(pkg.total_cost - pkg.discount) <> " " <> format_val(pkg.time)
      IO.puts(out)
      out
    end)
  end

  def parse_package(input, coupons, baseVal) do
    input
    |> Enum.map(fn a ->
      [sPkgID, sWgt, sDist, code] = String.split(a, [" ", "\n"], trim: true)
      {distance, _ } = Integer.parse(sDist)
      {weight, _ } = Integer.parse(sWgt)
      total = get_total(baseVal, distance, weight)

      %__MODULE__{
        packageID: sPkgID,
        distance: distance,
        weight: weight,
        total_cost: total,
        discount: get_discount(total, distance, weight, code, coupons)
      }
    end)
  end

  def format_val(val) do
    case val*1.00 |> Float.round(2) |> Float.to_string() |> Integer.parse() do
      {ret, ".0"} -> Integer.to_string(ret)
      _ -> val*1.00 |> Float.round(2) |> Float.to_string()
    end
  end

  def get_total(baseVal, distance, weight), do: baseVal + (10 * weight) + (5 * distance)

  def get_discount(total, distance, weight, sOfrCode, coupons) do
    case Enum.find(coupons, fn x -> x.couponid == sOfrCode end) do
      nil -> 0
      coupon ->
        case Coupon.is_valid_coup(coupon, distance, weight) do
          true -> total * coupon.discount / 100
          false -> 0
        end
    end
  end

end

defmodule FleetMgmt.Coupon do
  # Coupon Struct
  defstruct couponid: "",
            discount: nil,
            min_dist: nil,
            max_dist: nil,
            min_weight: nil,
            max_weight: nil

  def get_coupons(coupons) do
    coupons
    |> Poison.decode!()
    |> Enum.map(fn coupon ->
      %__MODULE__{
        couponid: coupon["id"],
        discount: coupon["discount"],
        min_dist: coupon["min_dist"],
        max_dist: coupon["max_dist"],
        min_weight: coupon["min_weight"],
        max_weight: coupon["max_weight"]
      }
    end)
  end

  def is_valid_coup(coupon, distance, weight),
    do:
      coupon.min_dist <= distance and distance <= coupon.max_dist and coupon.min_weight <= weight and
        weight <= coupon.max_weight
end

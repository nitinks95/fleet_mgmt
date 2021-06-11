alias FleetMgmt.{Coupon, Package, Shipment}

#add coupons
coupons = "coupons.json" |> File.read! |> Poison.decode!() |> Enum.map(fn coupon ->
  %Coupon{
    couponid: coupon["id"],
    discount: coupon["discount"],
    min_dist: coupon["min_dist"],
    max_dist: coupon["max_dist"],
    min_weight: coupon["min_weight"],
    max_weight: coupon["max_weight"]
  }
end)

## input ##
# 100 3
# PKG1 5 5 OFR001
# PKG2 15 5 OFR002
# PKG3 10 100 OFR003
# 1 50 20

baseVal = 100
pkgs = 3

inp_wot = ["PKG1 5 5 OFR001\n", "PKG2 15 5 OFR002\n", "PKG3 10 100 OFR003\n"]
inp_wt = ["PKG1 5 5 OFR001\n", "PKG2 15 5 OFR002\n", "PKG3 10 100 OFR003\n", "1 50 20\n"]

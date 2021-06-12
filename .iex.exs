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

inp_wt1 = ["PKG1 50 30 OFR001\n", "PKG2 75 125 OFFR0008\n", "PKG3 175 100 OFFR003\n", "PKG4 110 60 OFR002\n", "PKG5 155 95 NA\n", "2 70 200\n"]
inp_wot1 = ["PKG1 50 30 OFR001\n", "PKG2 75 125 OFFR0008\n", "PKG3 175 100 OFFR003\n", "PKG4 110 60 OFR002\n", "PKG5 155 95 NA \n"]

inp_pkg_list = inp_wot |> Package.parse_package(coupons, baseVal)

max_weight = 20

sorted_list = inp_pkg_list |> Shipment.sort_packages([], max_weight)
ship_list = sorted_list |> Shipment.create_shipment()



inp_pkg_list1 = inp_wot1 |> Package.parse_package(coupons, baseVal)

max_weight1 = 200

sorted_list1 = inp_pkg_list1 |> Shipment.sort_packages([], max_weight1)
ship_list1 = sorted_list1 |> Shipment.create_shipment()
ship_time_list = ship_list1 |> Shipment.calculate_time([1, 2], 70)

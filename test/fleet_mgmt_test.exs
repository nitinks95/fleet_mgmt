defmodule FleetMgmtTest do
  use ExUnit.Case
  alias FleetMgmt.{Coupon, Package, Shipment}
  doctest FleetMgmt

  @coupons_input "[\n    {\n        \"id\": \"OFR001\",\n        \"discount\": 10,\n        \"min_dist\": 0,\n        \"max_dist\": 200,\n        \"min_weight\": 70,\n        \"max_weight\": 200\n    },\n    {\n        \"id\": \"OFR002\",\n        \"discount\": 7,\n        \"min_dist\": 50,\n        \"max_dist\": 150,\n        \"min_weight\": 100,\n        \"max_weight\": 250\n    }\n]"
  @package_input ["PKG1 5 5 OFR001\n","PKG2 15 5 OFR002\n","PKG3 100 100 OFR002\n"]
  @package_outut ["PKG1 0 175","PKG2 0 275","PKG3 112 1488"]
  @package_time_output ["PKG1 0 175 0.1","PKG2 0 275 2","PKG3 112 1488 0.1"]
  @fleet_dtls = ["1", "50", "20"]

  describe "get_coupons/1" do

    test "Two coupons added to list" do
      assert Coupon.get_coupons(@coupons_input) |> length() == 2
    end

    test "Validate id of first coupon" do
      assert hd(Coupon.get_coupons(@coupons_input)).couponid == "OFR001"
    end

    test "Validate discount of first coupon" do
      assert hd(Coupon.get_coupons(@coupons_input)).discount == 10
    end

    test "Validate Minimum distance of first coupon" do
      assert hd(Coupon.get_coupons(@coupons_input)).min_dist == 0
    end

    test "Validate Maximum distance of first coupon" do
      assert hd(Coupon.get_coupons(@coupons_input)).max_dist == 200
    end

    test "Validate minimum weight of first coupon" do
      assert hd(Coupon.get_coupons(@coupons_input)).min_weight == 70
    end

    test "Validate maximum weight of first coupon" do
      assert hd(Coupon.get_coupons(@coupons_input)).max_weight == 200
    end

  end

  describe "is_valid_coup/3" do

    test "valid coupon" do
      assert @coupons_input |> Coupon.get_coupons |> hd() |> Coupon.is_valid_coup(100, 100)
    end

    test "invalid coupon as distance out of range" do
      assert @coupons_input |> Coupon.get_coupons |> hd() |> Coupon.is_valid_coup(300, 100) == false
    end

    test "invalid coupon as weight out of range" do
      assert @coupons_input |> Coupon.get_coupons |> hd() |> Coupon.is_valid_coup(100, 10) == false
    end

    test "invalid coupon as both distance and weight out of range" do
      assert @coupons_input |> Coupon.get_coupons |> hd() |> Coupon.is_valid_coup(300, 10) == false
    end

  end

  describe "parse_package/1" do

    test "validate 3 packages in input" do
      assert @package_input |> Package.parse_package(Coupon.get_coupons(@coupons_input), 100) |> length() == 3
    end

    test "validate packageID" do
      assert (@package_input |> Package.parse_package(Coupon.get_coupons(@coupons_input), 100) |> hd()).packageID == "PKG1"
    end

    test "validate distance" do
      assert (@package_input |> Package.parse_package(Coupon.get_coupons(@coupons_input), 100) |> hd()).distance == 5
    end

    test "validate weight" do
      assert (@package_input |> Package.parse_package(Coupon.get_coupons(@coupons_input), 100) |> hd()).weight == 5
    end

  end

  describe "get_total/3" do

    test "validate total cost formula1" do
      assert Package.get_total(100, 100, 50) == 1100
    end

    test "validate total cost formula2" do
      assert Package.get_total(100, 5, 5) == 175
    end

  end

  describe "get_discount/5" do

    test "calculate discount for success scenario" do
      assert Package.get_discount(1600, 100, 100, "OFR001", Coupon.get_coupons(@coupons_input)) == 160
    end

    test "calculate discount for failure scenario1" do
      assert Package.get_discount(175, 10, 5, "ORF001", Coupon.get_coupons(@coupons_input)) == 0
    end

    test "calculate discount for failure scenario2" do
      assert Package.get_discount(1600, 100, 100, "NA", Coupon.get_coupons(@coupons_input)) == 0
    end

  end


  test "check scenario 1" do
    assert @package_input |> Package.parse_package(Coupon.get_coupons(@coupons_input), 100) |> Package.format_output() == @package_outut
  end

  test "check scenario 2" do
    assert @package_input |> Package.parse_package(Coupon.get_coupons(@coupons_input), 100) |> Shipment.get_time_taken(@fleet_dtl) |> Package.format_output() == @package_outut
  end

end

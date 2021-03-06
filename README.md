# Fleet Management System

This is an application to manage the fleet for a small distance courier service started by Kiki, Tombo and Joji. The main features offered by the system are Calculating the total delivery cost, total delivery time and manage coupons and calculate the relevant coupon for the package based on the packages. This a CLI based application to solve the real time issues. 

### Design Considerations - 

* **Delivery Cost = Base Delivery Cost + (Package Total weight * 10) + (Distance to Destination * 5)**
* Input will be a multi-lined command line input where the first line will have `base_delivery_cost` and `no_of_packages` separated by a space character. Following `n` lines will have package details in order of `pkg_id1`, `weight1_in_kg`, `distance1_in_km` and `offer_ode` separated by space character and the last line will have the `no_of_vehicles` in fleet, `max_speed` and `max_carriable_weight` as well separated by space character.
* The available coupons will be defined in the JSON file and should be placed in the root directory. The format of JSON file is shown below and if the distance is in the limits of minimum and maximum range specified in the coupon and the weight of the package to which coupon is applied for is in the range of minimum and maximum weight mentioned in the coupon, then the coupon will be eligible for discount else Discount price will be zero. 
* And finally, **Total Cost = Delivery Cost - (Discount * Delivery Cost / 100)**
* Calculate the total time Taken for every shipment to be delivered.

---

## Technical stack 

This application is built using elixir, although to execute this application [erlang v11.0](https://erlang.org/doc/installation_guide/users_guide.html) and above should be installed or even [elixir v1.10](https://elixir-lang.org/install.html) and above can also be installed. 
Libraries used are:
* [Poison v3.1](https://hex.pm/packages/poison) : For Encoding and Decoding JSON

---
## Usage

### Dev-
* Clone the repository
* Run the test scenarios `mix test`. Navigate to `./test/fleet_mgmt_test.exs`
* Run `mix coveralls` to get overall summary and coverage of test cases
* Build the project `MIX_ENV=prod mix escript.build`
* Run `./fleet_mgmt -c "path_to_coupons.json"`

### Realtime-
* Clone the repository to local
  ![](img/clone.PNG "Local Repo")

* execute `make build`
  ![](img/make_build.PNG "make build command")

* execute `make run` and provide a same input
  ![](img/make_run.PNG "make run command")

* And output should be as follows - 
  ![](img/output.PNG "output")
---

## Input

### Input structure: 
```
base_delivery_cost no_of_packages
pkg_id1 pkg_weight1_in_kg distance1_in_km offer_code1
...
no_of_vehicles max_speed max_carriable_weight
```
### Example
```
100 3
PKG1 5 5 OFR001
PKG2 15 5 OFR002
PKG3 10 100 OFR003
1 50 20
```
---

## Output

### Output structure: 
```
pkg_id1 discount1 total_cost1 estimated_delivery_time1_in_hours
...
```
### Example
```
PKG1 0 175 0.1
PKG2 0 275 0.1
PKG3 35 665 2
```
---
## Coupon Structure
```json
[
    {
        "id": "String.t()",
        "discount": "Integer.t()",
        "min_dist": "Integer.t()",
        "max_dist": "Integer.t()",
        "min_weight": "Integer.t()",
        "max_weight": "Integer.t()"
    },...
]
```
---


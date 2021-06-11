defmodule FleetMgmt.Shipment do
  # Shipment Struct
  defstruct shipment_no: nil, vehicle: nil, packages: nil, max_time: nil, is_returned: false

  def get_time_taken(packages, [vehicles, speed, weight]) do
    fleet_list = get_fleet_list(vehicles)
    {max_speed, _} = Integer.parse(speed)
    {max_weight, _} = Integer.parse(weight)

    packages
    # Groups the packages based on max_weight and sorts the packages in descending order
    |> sort_packages([], max_weight)
    # Shipment struct is created to decide the time
    |> create_shipment()
    # Time when the shipment is delivered is calculated
    |> calculate_time(fleet_list, max_speed)
    |> Enum.reduce([], fn x, acc -> List.flatten([x.packages | acc]) end)
    |> Enum.sort_by(& &1.packageID, :asc)
  end

  def calculate_time(shipments, fleet_list, max_speed) do
    %{shipments: ship_list} =
      shipments
      |> Enum.reduce(%{fleet: fleet_list, shipments: []}, fn shipment, acc ->
        if length(acc.fleet) > 0 do
          fleet_list = acc.fleet
          acc = Map.put(acc, :fleet, tl(fleet_list))

          Map.put(acc, :shipments, [
            get_updated_shipment(shipment, 0, max_speed, hd(fleet_list)) | acc.shipments
          ])
        else
          ship_list = acc.shipments |> Enum.sort_by(& &1.max_time, :asc)

          first_ship =
            ship_list
            |> Enum.filter(fn x -> !x.is_returned end)
            |> hd()
            |> Map.put(:is_returned, true)

          Map.put(acc, :shipments, [
            get_updated_shipment(shipment, first_ship.max_time * 2, max_speed, first_ship.vehicle)
            | ship_list
          ])
        end
      end)

    ship_list
  end

  def get_updated_shipment(shipment, start_time, max_speed, fleet_number) do
    pkgs =
      shipment.packages
      |> Enum.map(fn package ->
        package
        |> Map.put(:time, ( package.distance / max_speed ) + start_time)
      end)

    total_time =
      pkgs
      |> Enum.max_by(& &1.time)
      |> Map.get(:time)

    shipment
    |> Map.put(:packages, pkgs)
    |> Map.put(:max_time, total_time)
    |> Map.put(:vehicle, fleet_number)
  end

  def create_shipment(packages) do
    packages
    |> Enum.with_index(1)
    |> Enum.map(fn {pkg, index} ->
      %__MODULE__{
        shipment_no: index,
        packages: pkg,
        is_returned: false
      }
    end)
  end

  def get_fleet_list(vehicles) do
    {total, _} = Integer.parse(vehicles)
    Enum.to_list(1..total)
  end


  def sort_packages([], acc, _max) do
		acc
	end

	def sort_packages(input, acc, max) do
		best_pkg = get_best_pkg_list(input, max)

		List.myers_difference(best_pkg, input)  |> Enum.reduce([], fn x, a ->
			case x do
				{:ins, val} -> List.flatten([a|val])
				_ -> a
			end
		end)
		|> sort_packages(acc ++ [best_pkg], max)
	end

	def get_best_pkg_list(input, max) do
		out = input
		|> powerset()
		|> Enum.filter(fn x -> Enum.reduce(x, 0, fn y, acc -> y.weight + acc end) <= max end)
		|> Enum.sort_by(&length/1, :desc)

		len = out
			|> hd()
			|> length()

		out1 = out
			|> Enum.filter(fn x -> length(x) == len end)
			|> Enum.map(fn x ->
				%{
					total_weight: Enum.reduce(x, 0, fn y, acc -> y.weight + acc end),
					max_distance: Map.get(Enum.max_by(x, &(&1.distance)), :distance),
					packages: x
				}
			end)

		out2 = out1
			|> Enum.sort_by(&(&1.total_weight), :desc)

		case length(out2) do
			1 -> hd(out2)
			_ -> weight = Map.get(hd(out2), :total_weight)
				out2
				|> Enum.filter(fn x -> x.total_weight == weight end) |> Enum.sort_by(&(&1.max_distance)) |> hd()
		end
		|> Map.get(:packages)
	end

  #To create Powerset of the list
  def powerset([]), do: [[]]
	def powerset([h|t]) do
		pt = powerset(t)
		powerset(h, pt, pt)
	end

	defp powerset(_, [], acc), do: acc
	defp powerset(x, [h|t], acc), do: powerset(x, t, [[x|h] | acc])

end

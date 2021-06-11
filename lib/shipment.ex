defmodule FleetMgmt.Shipment do
  # Shipment Struct
  defstruct shipment_no: nil, vehicle: nil, packages: nil, max_time: nil, is_returned: false

  def get_time_taken(packages, [vehicles, speed, weight]) do
    fleet_list = get_fleet_list(vehicles)
    {max_speed, _} = Integer.parse(speed)
    {max_weight, _} = Integer.parse(weight)

    packages
    # Groups the packages based on max_weight and sorts the packages in descending order
    |> sort_packages(max_weight)
    # Shipment struct is created to decide the time
    |> create_shipment()
    # Time when the shipment is delivered is calculated
    |> calculate_time(fleet_list, max_speed)
    |> Enum.reduce([], fn x, acc -> List.flatten([x.packages | acc]) end)
  end

  def calculate_time(shipments, fleet_list, max_speed) do
    %{shipments: ship_list} =
      shipments
      |> Enum.reduce(%{fleet: fleet_list, shipments: []}, fn shipment, acc ->
        if length(acc.fleet) > 0 do
          fleet_list = acc.fleet
          _ = Map.put(acc, :fleet, tl(fleet_list))

          Map.put(acc, :shipments, [
            get_updated_shipment(shipment, 0, max_speed, hd(acc.fleet)) | acc.shipments
          ])
        else
          ship_list = acc.shipments |> Enum.sort_by(& &1.max_time, :desc)

          first_ship =
            ship_list
            |> Enum.filter(fn x -> !x.is_returned end)
            |> hd()
            |> Map.put(:is_returned, true)

          Map.put(acc, :shipments, [
            get_updated_shipment(shipment, first_ship.max_time * 2, max_speed, hd(acc.fleet))
            | tl(ship_list)
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
        |> Map.put(:time, package.distance / max_speed + start_time)
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

  def sort_packages(input, max) do
    chunk_fn = fn element, chunk ->
      if length(chunk) == 0 or
           (length(chunk) > 0 and
              Enum.reduce(chunk, 0, fn x, acc -> x.weight + acc end) + element.weight <= max) do
        {:cont, [element | chunk]}
      else
        {:cont, Enum.reverse(chunk), [element]}
      end
    end

    after_fun = fn
      acc -> {:cont, Enum.reverse(acc), []}
    end

    Enum.sort_by(input, & &1.weight, :asc)
    |> Stream.chunk_while([], chunk_fn, after_fun)
    |> Enum.to_list()
  end

  def get_fleet_list(vehicles) do
    {total, _} = Integer.parse(vehicles)
    Enum.to_list(1..total)
  end
end

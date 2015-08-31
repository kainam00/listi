# Basic util functions

def get_name(instance)
	instance.tags.each do |tag|
		if tag.key == "Name"
			return tag.value
		end
	end
end

def output(reservations, outputargs=nil)
  if outputargs.has_key?("batch")
    output = Array.new()
    if outputargs.has_key?("num")
      reservations.each do |reservation|
        if outputargs["num"] > 0
          output << reservation.instances[0].private_ip_address
          outputargs["num"] = outputargs["num"] - 1
        end
      end
    else
      reservations.each do |reservation|
        output << reservation.instances[0].private_ip_address
      end
    end
    puts output.join(",")
  else
    reservations.each do |reservation|
      puts get_name(reservation.instances[0]) + ',' + reservation.instances[0].private_ip_address
    end
  end
end

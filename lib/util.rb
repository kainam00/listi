# Basic util functions

def get_name(instance)
	instance.tags.each do |tag|
		if tag.key == "Name"
			return tag.value
		end
	end
end


def output(reservations, outputargs=nil)
  reservations.each do |reservation|
    puts get_name(reservation.instances[0])+ ',' + reservation.instances[0].private_ip_address
  end
end

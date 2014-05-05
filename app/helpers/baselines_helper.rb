module BaselinesHelper

  def convert_to_chart(hash_with_data)
    #flot.js uses milliseconds in the date axis.
    hash_converted = Hash[hash_with_data.map{ |k, v| [k.to_time.to_i * 1000, v] }]
    #flot.js consumes arrays.
    hash_converted.to_a
  end
  
end

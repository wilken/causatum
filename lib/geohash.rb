module Ultraplex
  class GeoHash
  
    @@base_32_conversion = "0123456789bcdefghjkmnpqrstuvwxyz"
  
    def self.encode(latitude, longtitude, precision)
      latitude_code = encode_binary(latitude, -90.0, 90.0, precision)
      longtitude_code = encode_binary(longtitude, -180.0, 180.0, precision)
      j=0
      k=0
      geohash=""
      tmp=""
      (latitude_code.length + longtitude_code.length).times do |i| 
        if i % 2 == 1
          tmp += latitude_code[j,1]
          j=j+1
        else
          tmp += longtitude_code[k,1]
          k=k+1
        end
      end
      tmp+="00000"
      (tmp.length/5).times do |i|
        geohash += @@base_32_conversion[tmp[i*5,5].to_i(2),1]
      end
      return geohash
    end
  
    def self.decode(geohash)
      latitude_code=""
      longtiude_code=""
      tmp = geohash.collect do |c|
        ("00000" + @@base_32_conversion.index(c).to_s(2))[-5..-1]
      end
      tmp.each byte_with_index do |b,i|
        c = b.chr
        if i % 2 ==1
          lattitude_code += c
        else
          longitude_code += c
        end
      end
      latitude = decode_binary(latitude_code, -90.0, 90.0)
      longtitude = decode_binary(lomgtitude_code, -180.0, 180.0)
      
      return [latitude, longtitude]
    end
  
    def self.encode_binary(number, min, max, precision)
      code=""
      precision.times do
        if (number - min) < (max - number)
          max = (max - min) / 2 + min
          code += "0"
        else
          min = (max - min) / 2 + min
  				code += "1"
        end
      end
      return code
    end
  
    def self.decode_binary(code, min, max)
      code.each_byte do |b|
        if b.chr=='0'
          max = (max - min) / 2 + min
        else
          min = (max - min) / 2 + min
        end
      end
      return (max - min) / 2 + min   
    end
  end
end
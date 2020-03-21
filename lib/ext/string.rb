class String
  # Assumes key.length <= string.length
  def xor(key)
    xored = ""
    i = 0
    each_byte do |c|
      xored += (c ^ key[i % key.length].bytes.first).chr
      i += 1
    end
    xored
  end
end

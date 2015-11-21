class ImageCharArray
  PER_LINE = 10
  attr :name
  attr :width
  attr :height
  attr :data
  attr :mask_data

  def initialize(img, name)
    @width = img.width
    @height = img.height
    @mask = false
    @name = name
    @data = []
    @mask_data = []
  end

  def variable_name
    File.basename(name, '.*').gsub('-', '_')
  end

  def mask_name
    variable_name + '_mask'
  end

  def plus_mask_name
    variable_name + '_plus_mask'
  end

  def masked!
    @mask = true
  end

  def mask?
    @mask
  end

  def image_data(data)
    core = ''
    data.each_with_index do |x, i|
      hex = x.to_s(16).upcase
      core << '0x' + (hex.length==1 ? '0' : '') + hex
      core << ', ' unless i == @data.size-1
      core << "\n" if (i+1)%PER_LINE==0
    end
    core
  end

  def interlace(image, mask)
    a = []
    while image.size > 0
      a << image.shift
      a << mask.shift
    end
    a
  end

  def to_s
    o = "// #{File.basename(name)} / #{width}x#{height}\n"
    o << "PROGMEM const unsigned char #{variable_name}[] = {\n"
    o << image_data(@data)
    o << "\n};\n\n"
    if mask?
      o << "PROGMEM const unsigned char #{mask_name}[] = {\n"
      o << image_data(@mask_data)
      o << "\n};\n\n"

      o << "PROGMEM const unsigned char #{plus_mask_name}[] = {\n"
      o << image_data(interlace(@data, @mask_data))
      o << "\n};\n\n"

    end
    o
  end
end
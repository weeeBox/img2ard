require 'chunky_png'

require_relative 'asset_file'
require_relative 'image_char_array'

task :init do
  $dir_output = File.expand_path 'output'
end

desc 'Convert all files in the selected directory to drawBitmap binary format'
task :convert_files, [:path] do |t, args|

  path = args[:path]
  raise 'Please provide path' if path.nil?
  raise "Path not found: #{path}" unless File.directory? path

  resource = AssetFile.new File.basename(path)

  Dir["#{path}/**/*.png"].each do |file|

      img = ChunkyPNG::Image.from_file(file)
      # puts img.inspect
      out = ImageCharArray.new(img, file)
      puts "#{file}: #{img.width}x#{img.height}"

      bits_last_page = img.height % 8
      bytes_high = img.height / 8
      bytes_high +=1 if bits_last_page>0

      (0..bytes_high - 1).each do |y_page|
        (0..img.width - 1).each do |x|
          # how many bits does this line hold
          bits = 8
          # if we've reached the bottom there are fewer bits to load
          bits = bits_last_page if bytes_high-1==y_page and bits_last_page > 0
          byte = 0
          alpha_byte = 0
          (0..bits-1).each do |bit_height|
            px = img[x, y_page*8 + bit_height]
            # right now we only care about black/white so convert to greyscale
            c = ChunkyPNG::Color.grayscale_teint(px)
            alpha = ChunkyPNG::Color.a(px)
            if c > 128 and not alpha < 128
              byte += (1 << (bit_height))
            end

            if alpha > 128 # visible
              alpha_byte += (1 << (bit_height))
              out.masked!
            end
          end
          out.mask_data << (alpha_byte)
          out.data << byte
        end
      end
      # puts out.inspect
      resource.files << out

  end

  File.open(resource.filename, 'w') do |f|
    f.write resource.to_s
  end
  puts "\n#{resource.filename} compiled."

end

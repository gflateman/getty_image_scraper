require 'rubygems'
require 'rmagick'
include Magick

class ImageAnnotater

  PADDING_X = 100
  PADDING_Y = 200
  # refactor to initialize?
  SCREEN_WIDTH = 2880.0
  SCREEN_HEIGHT = 1800.0
  SCREEN_DIMENSION_RATIO = SCREEN_HEIGHT / SCREEN_WIDTH

  BASE_HEIGHT_OFFSET = (SCREEN_HEIGHT / 2 ) - PADDING_Y
  BASE_WIDTH_OFFSET = -1 * ((SCREEN_WIDTH / 2) - PADDING_X)

  def initialize(image_path, info_hash)
    @draw = Draw.new
    @image = Image.read(image_path).first
    @text = self.format_text(info_hash)
  end

  def width
    @image.columns.to_f # width px
  end

  def height
    @image.rows.to_f #height in px
  end

  def dimension_ratio
    self.height / self.width
  end

  def scale_factor
    if self.dimension_ratio < SCREEN_DIMENSION_RATIO
      # landscape
      return (self.height / SCREEN_HEIGHT).to_f
    else
      # portrait
      return (self.width / SCREEN_WIDTH).to_f
    end
  end

  def format_info_line(k,v)
    return '' if k.to_s.downcase.match('dimensions')
    return "#{k}: #{v.upcase}\n" if k.to_s.match("ID")
    return "#{v.upcase}\n"
  end

  def format_text(info_hash)
    text = ""
    info_hash.each do |k,v|
      text << self.format_info_line(k,v)
    end
    return text
  end

  def annotate

    width_offset = self.scale_factor * BASE_WIDTH_OFFSET
    height_offset = self.scale_factor * BASE_HEIGHT_OFFSET

    annotated_image = @image.annotate(@draw, 0, 0, (self.width/2) + width_offset, (self.height/2) + height_offset, @text) {
      self.align = LeftAlign
      self.font_weight = BoldWeight
      self.pointsize = 32
      self.font_family = 'Helvetica'
      self.fill = 'white'
      self.stroke = '#000000'
    }
    return annotated_image
  end

end



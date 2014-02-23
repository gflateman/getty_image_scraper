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

  def initialize
    @draw = Draw.new
  end

  def width( image )
    image.columns.to_f # width px
  end

  def height( image )
    image.rows.to_f #height in px
  end

  def dimension_ratio( image )
    height(image) / width(image)
  end

  def scale_factor( image )
    if dimension_ratio(image) < SCREEN_DIMENSION_RATIO
      # landscape
      return (height(image) / SCREEN_HEIGHT).to_f
    else
      # portrait
      return (width(image) / SCREEN_WIDTH).to_f
    end
  end

  def format_info_line( k,v )
    return '' if k.to_s.downcase.match('dimensions')
    return "#{k}: #{v.upcase}\n" if k.to_s.match("ID")
    return "#{v.upcase}\n"
  end

  def format_text( info_hash )
    text = ""
    info_hash.each{ |k,v| text << format_info_line(k,v) }
    return text
  end

  def annotate( image_path, info_hash )

    image = Image.read(image_path).first
    text = format_text(info_hash)
    scale = scale_factor(image)

    width_offset = (width(image)/2) + (scale * BASE_WIDTH_OFFSET)
    height_offset = (height(image)/2) + (scale * BASE_HEIGHT_OFFSET)

    annotated_image = image.annotate(@draw, 0, 0, width_offset, height_offset, text) {
      self.align = LeftAlign
      self.font_weight = BoldWeight
      self.pointsize = 32
      self.font_family = 'Helvetica'
      self.fill = 'white'
      self.stroke = 'black'
    }
  end

end



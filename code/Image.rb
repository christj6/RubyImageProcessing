require 'chunky_png'

class Image 
  attr_reader :width, :height, :picturePath, :pictureName
  
  def initialize(path)
    @picturePath = File.split(path)[0]
    @pictureName = File.split(path)[1]
    
    @picture = ChunkyPNG::Image.from_file(path)
    @width = @picture.dimension.width
    @height = @picture.dimension.height
  end
  
  def savePicture(name, path = nil)
    path.nil? ? @picture.save(File.join(@picturePath, name)) : @picture.save(File.join(path, name))
  end
  
  def convertToGrayscale(name = nil, path = nil)
    if name.nil? then
      name = @pictureName.gsub('.png', 'Grayed.png')
    end
    grayImage = @picture.grayscale
    path.nil? ? grayImage.save(File.join(@picturePath, name)) : grayImage.save(File.join(path, name))
  end
  
  def convertToGrayscale!
    @picture.grayscale!
  end
  
  def sobelFilter(name = nil, pathForImage = nil, pathForSave = nil)
    if name.nil? then
      name = @pictureName.gsub('.png', 'SobelFilter.png')
    end
    
    if pathForImage.nil? then
      pathForImage = File.join(@picturePath, @pictureName.gsub('.png', 'Grayed.png'))
    end
    
    sobelFilterX = [[1, 2, 1], [0, 0, 0], [-1, -2, -1]]
    sobelFilterY = [[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]]
    height = @height-2
    width = @width-2
    copyImage = ChunkyPNG::Image.from_file(pathForImage)
    sobelPic = ChunkyPNG::Image.from_file(pathForImage)
    
    for j in 1..(height)
      for i in 1..(width)
        pixel1 = calculatePixelValueWithFilter3(sobelFilterX, copyImage, i, j, true)
        pixel2 = calculatePixelValueWithFilter3(sobelFilterY, copyImage, i, j, true)
        res = Math.sqrt(pixel1[0]*pixel1[0] + pixel2[0]*pixel2[0])
        sobelPic[i, j] = ChunkyPNG::Color.rgb(res.to_i, res.to_i, res.to_i)
      end
    end
    pathForSave.nil? ? sobelPic.save(File.join(@picturePath, name)) : sobelPic.save(File.join(pathForSave, name))
  end
  
  def blur(name = nil, pathForImage = nil, pathForSave = nil)
    if name.nil? then
      name = @pictureName.gsub('.png', 'Blurred.png')
    end
    
    if pathForImage.nil? then
      pathForImage = File.join(@picturePath, @pictureName)
    end
    
    blurFilter = [[1/16.0, 2/16.0, 1/16.0], [2/16.0, 4/16.0, 2/16.0], [1/16.0, 2/16.0, 1/16.0]]
    height = @height-2
    width = @width-2
    blur = ChunkyPNG::Image.from_file(pathForImage)
    for j in 1..(height)
      for i in 1..(width)
        pixel = calculatePixelValueWithFilter3(blurFilter, @picture, i, j, false)
        blur[i, j] = ChunkyPNG::Color.rgb(pixel[0].to_i, pixel[1].to_i, pixel[2].to_i)
      end
    end
    pathForSave.nil? ? blur.save(File.join(@picturePath, name)) : blur.save(File.join(pathForSave, name))
  end
  
  def gaussianBlur(name = nil, pathForImage = nil, pathForSave = nil)
    if name.nil? then
      name = @pictureName.gsub('.png', 'Gauss.png')
    end
    
    if pathForImage.nil? then
      pathForImage = File.join(@picturePath, @pictureName)
    end
    
    blurFilter = 
    [
      [0.01248, 0.02642, 0.03392, 0.02642, 0.01248], 
      [0.02642, 0.05592, 0.07180, 0.05592, 0.02642], 
      [0.03392, 0.07180, 0.09220, 0.07180, 0.03392], 
      [0.02642, 0.05592, 0.07180, 0.05592, 0.02642], 
      [0.01248, 0.02642, 0.03392, 0.02642, 0.01248], 
    ]

    height = @height-3
    width = @width-3
    blur = ChunkyPNG::Image.from_file(pathForImage)
    for j in 2..(height)
      for i in 2..(width)
        pixel = calculatePixelValueWithFilter5(blurFilter, @picture, i, j, false)
        blur[i, j] = ChunkyPNG::Color.rgb(pixel[0].to_i, pixel[1].to_i, pixel[2].to_i)
      end
    end
    pathForSave.nil? ? blur.save(File.join(@picturePath, name)) : blur.save(File.join(pathForSave, name))
  end
  
  def sharpen(name = nil, pathForImage = nil, pathForSave = nil)
    if name.nil? then
      name = @pictureName.gsub('.png', 'Sharpened.png')
    end
    
    if pathForImage.nil? then
      pathForImage = File.join(@picturePath, @pictureName)
    end
    
    sharpenFilter = [[-1, -1, -1], [-1, 9, -1], [-1, -1, -1]]
    
    height = @height-2
    width = @width-2
    sharpen = ChunkyPNG::Image.from_file(pathForImage)
    for j in 1..(height)
      for i in 1..(width)
        pixel = calculatePixelValueWithFilter3(sharpenFilter, @picture, i, j, false)
        sharpen[i, j] = ChunkyPNG::Color.rgb(pixel[0], pixel[1], pixel[2])
      end
    end
    pathForSave.nil? ? sharpen.save(File.join(@picturePath, name)) : sharpen.save(File.join(pathForSave, name))
  end
  
  def calculatePixelValueWithFilter3(filter, img, currX, currY, grayscale)
    value = [0, 0, 0]
    for i in 0..2
      for j in 0..2
        if grayscale then
          value[0] += filter[i][j] * ChunkyPNG::Color.r(img[(currX-1)+j, (currY-1)+i])
        else
          value[0] += filter[i][j] * ChunkyPNG::Color.r(img[(currX-1)+j, (currY-1)+i])
          value[1] += filter[i][j] * ChunkyPNG::Color.g(img[(currX-1)+j, (currY-1)+i])
          value[2] += filter[i][j] * ChunkyPNG::Color.b(img[(currX-1)+j, (currY-1)+i])
        end
      end
    end
    return constrainToColors(value)
  end
  
  def calculatePixelValueWithFilter5(filter, img, currX, currY, grayscale)
    value = [0, 0, 0]
    for i in 0..4
      for j in 0..4
        if grayscale then
          value[0] += filter[i][j] * ChunkyPNG::Color.r(img[(currX-2)+j, (currY-2)+i])
        else
          value[0] += filter[i][j] * ChunkyPNG::Color.r(img[(currX-2)+j, (currY-2)+i])
          value[1] += filter[i][j] * ChunkyPNG::Color.g(img[(currX-2)+j, (currY-2)+i])
          value[2] += filter[i][j] * ChunkyPNG::Color.b(img[(currX-2)+j, (currY-2)+i])
        end
      end
    end
    return constrainToColors(value)
  end
  
  private
  def constrainToColors(array)
    array[0] > 255 ? array[0] = 255 : array[0] < 0 ? array[0] = 0 : array[0]
    array[1] > 255 ? array[1] = 255 : array[1] < 0 ? array[1] = 0 : array[1]
    array[2] > 255 ? array[2] = 255 : array[2] < 0 ? array[2] = 0 : array[2]
    return array
  end
  
end
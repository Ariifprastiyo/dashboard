# frozen_string_literal: true

require 'magic_cloud'
require 'tempfile'

class WordCloudGeneratorService
  # it will return the word cloud image, it can be attached to any model
  def call(word_hash)
    words = word_hash.map { |word, weight| [word, weight] }
    cloud = MagicCloud::Cloud.new(words, rotate: :none, scale: :log)
    img = cloud.draw(960, 600)

    # Create a temporary file
    temp_file = Tempfile.new(['word_cloud', '.png'])
    img.write(temp_file.path)

    # Return the path to the temporary file
    temp_file.path
  ensure
    temp_file.close if temp_file
  end
end

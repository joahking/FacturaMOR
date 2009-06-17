# == Schema Information
#
# Table name: logos
#
#  id           :integer(4)      not null, primary key
#  parent_id    :integer(4)
#  content_type :string(255)
#  filename     :string(255)
#  db_file_id   :integer(4)
#  thumbnail    :string(255)
#  size         :integer(4)
#  width        :integer(4)
#  height       :integer(4)
#

class Logo < ActiveRecord::Base
  has_one  :fiscal_data, :dependent => :nullify
  has_many :invoices, :dependent => :nullify

  has_attachment :content_type => :image,
                 :storage      => :db_file,
                 :max_size     => 500.kilobytes, # this 500 is hard-coded in fdata/_form.rhtml
                 :thumbnails   => {:web => '150x100', :pdf => '150x100'},
                 :processor    => 'MiniMagick'

  validates_as_attachment

  def validate
    unless filename =~ /\.(?:jpeg|jpg|gif|png|eps)\z/i
      errors.add_to_base('los formatos gráficos soportados son JPEG, GIF, PNG y EPS')
    end
  end

  # We normalize filenames because LaTeX does not recognize JPG as
  # a known extension for example, cause it is uppercase. This sanitizes
  # the filename as well.
  before_create :normalize_filename
  def normalize_filename
    self.filename = self.class.normalize_filename(filename)
  end

  def self.normalize_filename(filename)
    parts = filename.split('.').map {|x| FacturagemUtils.normalize(x)}.join('.')
  end

  def image_data(thumbnail=nil)
    if thumbnail
      thumbnails.find_by_thumbnail(thumbnail.to_s).current_data
    else
      current_data
    end
  end
end

require 'tempfile'
require 'extensions_const'

class File
  GENERIC = 'application/octet-stream'
  
  def self.mime_type?(file)
    case file
    when File, Tempfile
      mime = `file --mime -br "#{file.path}"`.strip unless RUBY_PLATFORM.include?('mswin32')
      mime = EXTENSIONS[File.extname(file.path).gsub('.','').downcase.to_sym] if mime == GENERIC || mime.nil?
      mime
    when String
      mime = EXTENSIONS[(file[file.rindex('.')+1, file.size]).downcase.to_sym] unless file.rindex('.').nil?
    when StringIO
      temp = File.open(Dir.tmpdir + '/upload_file.' + Process.pid.to_s, "wb")
      temp << file.string
      temp.close
      mime = `file --mime -br "#{temp.path}"`
      mime = mime.gsub(/^.*: */,"")
      mime = mime.gsub(/;.*$/,"")
      mime = mime.gsub(/,.*$/,"")
      File.delete(temp.path)
    end

    return mime || 'unknown/unknown'
   end

  def self.extensions
    EXTENSIONS
  end

end

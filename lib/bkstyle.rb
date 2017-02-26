require 'bkstyle/version.rb'
require 'bkstyle/upsfile.rb'
require 'logger'

def cli_options(global_options, options)
  loptions = global_options.clone
  loptions.update(options)
end

# Add requires for other files you add to your project here, so
# you just need to require this one file in your bin file

class Folder
  def initialize(srcdir, options={})
    @srcdir  = srcdir
    @tgtdir  = options[:target] || srcdir
    @options = options
    case @options[:src_mode]
    when /^(ari|cali)/
      @extension = 'mid'
    else
      @extension = 'STL'
    end
    @runopt = {verbose:true}
    @runopt[:noop] = true if @options[:dryrun]

    FileUtils.mkdir_p(@tgtdir, @runopt) unless test(?d, @tgtdir)
  end

  def get_files
    if @options[:recursive]
      `find "#{@srcdir}" -name '*.#{@extension}'`.split("\n")
    else
      Dir.glob("#{@srcdir}/*.#{@extension}")
    end
  end

  def map_target
    dirs    = Dir.glob("#{@tgtdir}/*").select {|f| test(?d, f)}
    @mapdirs = {}
    dirs.each do |adir|
      adir = File.basename(adir)
      if adir.size == 1
        @mapdirs[adir] = adir
      elsif adir =~ /([A-Z])-([A-Z])/
        $1.upto($2) do |c|
          @mapdirs[c] = adir
        end
      end
    end
    @mapdirs
  end

  def get_dfilename(f)
    dir, file = File.split(f)
    dd = nil
    case @options[:src_mode]
    when 'ari.n'
      if f !~ /(\d+).mid/
        return nil
      end
      fno = $1
      lf  = fno[0..2]
      dd  = "#{@tgtdir}/#{lf}"
    when 'cali.n'
      if f !~ /^(\d+)\s+/
        return nil
      end
      fno = $1
      lf  = fno[0..3]
      dd  = "#{@tgtdir}/#{lf}"
    when 'cali'
      fs   = file.split(' ', 3)
      lf   = fs[2][0]
      dd   = "#{@tgtdir}/#{lf}"
      song = fs[2].sub(/\.mid$/, '')
      file = "#{song} - #{fs[0]}.mid"
    else
      fc = file.sub(/^[^A-Z0-9]/io, '')
          .sub(/^A\s+/io, '')[0].upcase
      lf = @mapdirs[fc] || fc
      lf = '0-9' if lf =~ /^\d$/
      dd = "#{@tgtdir}/#{lf}"
    end
    return nil unless dd
    FileUtils.mkdir_p(dd, @runopt) unless test(?d, dd)
    "#{dd}/#{file}"
  end

  def split_dir
    map_target
    get_files.each do |f|
      dfile     = get_dfilename(f)
      unless @options[:force]
        next if test(?e, dfile)
      end
      if @options[:copy]
        FileUtils.cp(f, dfile, @runopt)
      else
        FileUtils.move(f, dfile, @runopt)
      end
    end
  end
end

def alphabetize_dir(dir, options={})
  runopt = {verbose:true}
  runopt[:noop] = true if options[:dryrun]

  tdir = options[:target] || dir
  FileUtils.mkdir_p(tdir, runopt) unless test(?d, tdir)
  
  dirs    = Dir.glob("#{tdir}/*").select {|f| test(?d, f)}
  mapdirs = {}
  dirs.each do |adir|
    adir = File.basename(adir)
    if adir.size == 1
      mapdirs[adir] = adir
    elsif adir =~ /([A-Z])-([A-Z])/
      $1.upto($2) do |c|
        mapdirs[c] = adir
      end
    end
  end
  
  extension = options[:extension] || 'STL'
  if options[:recursive]
    files = `find "#{dir}" -name '*.#{extension}'`.split("\n")
  else
    files = Dir.glob("#{dir}/*.#{extension}")
  end

  files.each do |f|
    dir, file = File.split(f)
    fc = file.sub(/^[^A-Z0-9]/io, '')
        .sub(/^A\s+/io, '')[0].upcase
    lf = mapdirs[fc] || fc
    lf = '0-9' if lf =~ /^\d$/
    dd = "#{tdir}/#{lf}"

    FileUtils.mkdir_p(dd, runopt) unless test(?d, dd)
    dfile = "#{dd}/#{File.basename(f)}"
    unless options[:force]
      next if test(?e, dfile)
    end
    if options[:copy]
      FileUtils.cp(f, dfile, runopt)
    else
      FileUtils.move(f, dfile, runopt)
    end
  end

  sdsize = {}
  Dir.glob("#{tdir}/*").select {|f| test(?d, f)}.each do |sdir|
    sdsize[sdir] = Dir.glob("#{sdir}/*STL").size
  end

  require 'yaml'
  puts sdsize.to_yaml
end
  

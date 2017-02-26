#!/usr/bin/env ruby
#---------------------------------------------------------------------------
# File:        upsfile.rb
# Date:        2017-02-25 19:10:07 -0800
# Copyright:   E*Trade, 2017
# $Id$
#---------------------------------------------------------------------------
#++

class UpsFile
  def initialize(file, options={})
    @file    = file
    @fid     = File.open(file, 'rb')
    @options = options
    @header  = @fid.read(32)
    @content = []
    @logger  = Logger.new(STDERR)
    while block = @fid.read(1252)
      @content << block
    end
    @logger.info "Reading #{@content.size} entries from #{@file}"
  end

  def list
    fcount = 0
    puts ''
    @content.each do |block|
      fcount += 1
      if block
        fname = block[0..31].sub(/\0.*$/o, '')
        style = block[715..746].sub(/\0.*$/o, '')
        puts "%2d. %-20s (%s)" % [fcount, fname, style]
      else
        puts "%2d. [empty]" % [fcount]
      end
    end
    true
  end

  def save(ofile=nil)
    ofile ||= @options[:ofile]
    unless ofile
      if test(?e, "#{@file}.bak")
        FileUtils.remove("#{@file}.bak", verbose:true)
      end
      @logger.info "Backup original file #{@file}"
      FileUtils.move(@file, "#{@file}.bak", verbose:true)
      ofile = @file
    end
    content = @content.compact
    @logger.info "Writing to #{ofile} - #{content.size} recs"
    File.open(ofile, "wb") do |fod|
      fod.write(@header)
      content.each do |block|
        fod.write(block)
      end
    end
  end

  def bedit(bfile)
    File.read(bfile).split("\n").each do |l|
      cmd, *args = l.split
      case cmd
      when 'compact'
        @content = @content.compact

      when 'delete'
        next unless args.size > 0
        args.each do |index|
          position = index.to_i - 1
          @content[position] = nil
        end

      when 'list'
        list

      when 'move'
        from_pos = args.shift.to_i - 1
        to_pos   = args.shift.to_i - 1
        @content.insert(to_pos, @content[from_pos])
        @content[from_pos] = nil

      when 'rename'
        position = args.shift.to_i - 1
        new_name = args.join(' ')
        buf      = @content[position]

        # Clear out the old stuff
        oname = buf[0..31].sub(/\0.*$/o, '')
        buf[0..oname.size-1] = "\0" * oname.size

        # Overwrite the new stuff
        buf[0..new_name.size-1] = new_name

      when 'write'
        ofile = args.shift
        save(ofile)

      end
    end
  end
end


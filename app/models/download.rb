# === COPYRIGHT:
#  Copyright (c) North Carolina State University
#  Developed with funding for the National eXtension Initiative.
# === LICENSE:
#  BSD(-compatible)
#  see LICENSE file

class Download < ActiveRecord::Base
  attr_accessible :label, :period, :filetype, :last_filesize, :objectclass, :objectmethod, :last_generated_at, :last_runtime, :method_writes_file

  # periods
  NONE = 0
  DAILY = 1
  WEEKLY = 2
  MONTHLY = 3

  def filename
    now = Time.now.utc
    case self.period
    when NONE
      "#{Rails.root}/#{Settings.downloads_data_dir}/#{self.label}.#{self.filetype}"
    when DAILY
      "#{Rails.root}/#{Settings.downloads_data_dir}/#{self.label}_#{now.strftime("%Y-%m-%d")}.#{self.filetype}"
    when WEEKLY
      "#{Rails.root}/#{Settings.downloads_data_dir}/#{self.label}_#{now.strftime("%G-%V")}.#{self.filetype}"
    when MONTHLY
      "#{Rails.root}/#{Settings.downloads_data_dir}/#{self.label}_#{now.strftime("%Y-%m")}.#{self.filetype}"
    end
  end


  def dump_to_file(forceupdate=false)
    this_filename = self.filename
    if(!self.updated? or forceupdate)
      object = Object.const_get(self.objectclass)
      benchmark = Benchmark.measure do
        if(self.method_writes_file)
          object.send(self.objectmethod,this_filename)
        else
          data = object.send(self.objectmethod)
          File.open(this_filename, 'w') {|f| f.write(data)}
        end
      end
      self.update_attributes(last_generated_at: Time.now, last_runtime: benchmark.real, last_filesize: File.size(this_filename))
    end
    this_filename
  end

  def updated?
    File.exists?(self.filename)
  end


end
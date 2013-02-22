# === COPYRIGHT:
#  Copyright (c) North Carolina State University
#  Developed with funding for the National eXtension Initiative.
# === LICENSE:
#  BSD(-compatible)
#  see LICENSE file

class AaeResponse < ActiveRecord::Base
  # connects to the aae database
  self.establish_connection :aae
  self.table_name='responses'

  belongs_to :question, class_name: 'AaeQuestion'

  scope :public, where("submitter_id IS NOT NULL")
  scope :expert, where("resolver_id IS NOT NULL")
end
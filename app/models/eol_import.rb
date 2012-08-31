# This class keeps track of the MD5 checksum of the 
# latest import of archives from EoL. It is used to 
# avoid importing archives that we've already got 
class EolImport < ActiveRecord::Base
  attr_accessible :checksum
end

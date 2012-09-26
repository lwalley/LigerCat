# Rails' STI can do all sorts of magic with finder methods automatically finding subclasses.
# This is a very good thing, that we use quite often do our advantage. The problem is, child
# classes are not recognized by the parent until they are loaded. 
#
# In typical Rails production and test environments this happens right away, 
#  ** but in development ** where config.cache_classes == false, classes aren’t loaded until
# you call upon them. So, for this to work consistently in our development environment we need
# to manually require classes:

if Rails.env.development?
  %w[query blast_query pubmed_query binomial_query].each do |c|
    require_dependency File.join("app","models","#{c}.rb")
  end
end
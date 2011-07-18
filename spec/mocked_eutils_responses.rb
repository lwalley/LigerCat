module MockedEutilsResponses
  # This little nugget of magic reads all the XML files in the mocked_eutils_responses directory
  # then defines a constant on this module, whose value is the string contents of the XML file.
  
  # I have since replaced this with FakeWeb, but not all specs have been updated yet

  
  Dir.chdir(File.dirname(__FILE__) + "/mocked_eutils_responses")
  Dir.glob("*.xml").each do |f|
    contents = File.open(f, 'rb').read
    const_name = f.chomp('.xml').upcase
    const_set(const_name, contents) unless const_defined? const_name
  end
end
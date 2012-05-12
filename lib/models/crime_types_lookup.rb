class CrimeTypesLookup
  def self.name_for_fbi_code(fbi_code)
    #puts 'fbi_code: ' + fbi_code
    #Cacheable::retain_in_cache(fbi_code) do
      DB.fetch(Crime::QUERIES[:category_name_by_fbi_code], :fbi_code => fbi_code).first[:name]
    #end
  end
  
  def self.crime_type(fbi_code)
    #puts 'fbi_code: ' + fbi_code
    #Cacheable::retain_in_cache(fbi_code) do
      DB.fetch(Crime::QUERIES[:category_name_by_fbi_code], :fbi_code => fbi_code).first
    #end
  end
end

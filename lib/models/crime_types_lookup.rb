class CrimeTypesLookup
  def self.name_for_fbi_code(fbi_code)
    puts 'fbi_code: ' + fbi_code
    DB.fetch(Crime::QUERIES[:category_name_by_fbi_code], :fbi_code => fbi_code).first[:name]
  end
end

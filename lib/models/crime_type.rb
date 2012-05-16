class CrimeType
  def self.find_by_fbi_code(fbi_code)
    DB.fetch(Crime::QUERIES[:category_name_by_fbi_code], :fbi_code => fbi_code).first
  end
end

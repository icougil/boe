# encoding: UTF-8

module PardonParser
  def self.get_BOE_id(filename)
    filename =~ /(BOE-.-\d{4}-\d+)/
    $1
  end

  def self.get_military_trial_details(p)
  end

  def self.get_trial_details(p)
    if p =~ /deserción/
      return get_military_trial_details(p)
    end

    p =~ /en sentencia de (\d+ de [a-z]+ de.\d{4}), (.*)$/
    trial_date = $1
    left_over = $2

    return trial_date
  end

  def self.parse_file(doc)
    title = doc.search(".documento-tit").text
    # TODO: Should probably not get the person name from the title: be more relaxed 
    # in regex to avoid missing odd ones
    if title =~ /se indulta a (do.*)\./ or title =~ /se concede el indulto .*? (do(n|ña) .*)\./
      name = $1 # Matches the name in the title

      # Get other relevant details from document
      department = doc.search('.valDoc')[2].text
      first_paragraph, second_paragraph = doc.search("p.parrafo")
      get_trial_details(first_paragraph.text)

      # We get the BOE date from the PDF url, easier than parsing the expanded human readable date
      pdf = doc.search('.puntoPDF a').first.attributes['href'].value
      pdf =~ /dias\/(\d{4})\/(\d{2})\/(\d{2})/
      year, month, day = $1, $2, $3

      puts CSV::generate_line([get_BOE_id(doc.url), "#{day}-#{month}-#{year}", department, name])
    end
  end
end

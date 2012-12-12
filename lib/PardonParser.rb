# encoding: UTF-8

# TODO: Some duplicated code below

module PardonParser
  # There are some funny non-breaking spaces in the content, we have to deal with those at some points
  NBSP = "\u00a0"

  def self.get_BOE_id(filename)
    filename =~ /(BOE-.-\d{4}-\d+)/
    $1
  end

  def self.get_military_trial_details(p)
    p.gsub!(NBSP, ' ') # Get rid of the funny whitespaces

    # This regex could be simpler, as all military cases seem to be about desertion, but I used the civil one as base
    p =~ /como ([^ ]+) de (.*?),? a la pena de (.*?)[,;] constando en el mismo/
    role, crime, sentence = $1, $2, $3

    return nil, role, crime, sentence, nil
  end

  def self.get_trial_details(p)
    p.gsub!(NBSP, ' ') # Get rid of the funny whitespaces

    # Split along sentence date
    p =~ /en sentencia de (\d+ de [^ ]+ de.\d{4}), (.*)$/
    sentence_date, left_over = $1, $2

    # Now get the role and crime from the remainder
    left_over =~ /como ([^ ]+) de (.*?),? a [^ ]+ penas? ((por cada (delito|uno de ellos) )?(de )?.*?)[,;] por hechos/    
    role, crime, sentence = $1, $2, $3

    # Useful while debugging new files
    $stderr.puts p if $3.nil?
    $stderr.puts left_over if $3.nil?

    # Get the time of the crime (trying to do this in previous regex gets messy because of many levels of brackets)
    left_over =~ /por hechos cometidos en (?:el|los) años? ([0-9\-]+)/
    crime_year = $1

    sentence.gsub!(/^de /,'') # Remove the 'de ' at the begining, if it exists

    return sentence_date, role, crime, sentence, crime_year
  end

  def self.get_military_pardon_details(p)
    p.gsub!(NBSP, ' ') # Get rid of the funny whitespaces

    # Find out the name of the person, and the type of perdon
    p =~ /((don|doña)( ((de la)|(de los)|del|de|[A-ZÁÉÍÓÚ][^ ,]+))+),? el (.*?) respecto/
    name, pardon_type = $1, $+
    left_over = $'

    # Find out what the new sentence is
    left_over =~ /remitiendo la misma por la de (.*)\./
    new_sentence = $1

    return pardon_type, name, new_sentence, nil
  end

  def self.get_pardon_details(p)
    p.gsub!(NBSP, ' ') # Get rid of the funny whitespaces

    # Find out the name of the person, and the type of perdon
    p =~ /^Vengo en (\w+) a ((don|doña)( ((de la)|(de los)|del|de|[A-ZÁÉÍÓÚ][^ ]+))+)/
    pardon_type, name = $1, $2
    left_over = $'

    # Useful while debugging new files
    $stderr.puts p if $1.nil?

    # Get some more details based on the 
    if ( pardon_type == 'conmutar' )
      # Note: ?: is a non-capturing group
      left_over =~ /^(?: todas)? las? (?:penas? .*?) por(?: otra(?: única)? de)? (.*?),? a condición de que (.*) desde la publicación del real decreto\./
      new_sentence, condition = $1, $2
      # TODO: Alert if not match
      return pardon_type, name, new_sentence, condition
    else
      left_over =~ /^ (.*?),? a condición de que (.*) desde la publicación del real decreto\./
      partial_pardon, condition = $1, $2
      # TODO: Alert if not match
      return pardon_type, name, partial_pardon, condition
    end
  end

  def self.parse_file(doc)
    title = doc.search(".documento-tit").text
    # Find out whether we have a pardon. Don't try to match the name in the title just in case, 
    # we're being very prudent here to avoid missing a pardon.
    if title =~ /se indulta a / or title =~ /se concede el indulto /
      # Get main details from document...
      department = doc.search('.valDoc')[2].text
      first_paragraph, second_paragraph = doc.search("p.parrafo")

      # ...and parse the two body paragraphs to extract fine details
      if department == 'Ministerio de Defensa'
        sentence_date, role, crime, sentence, crime_year = get_military_trial_details(first_paragraph.text)
        pardon_type, name, pardon, condition = get_military_pardon_details(second_paragraph.text)
      else
        sentence_date, role, crime, sentence, crime_year = get_trial_details(first_paragraph.text)
        pardon_type, name, pardon, condition = get_pardon_details(second_paragraph.text)
      end

      # We get the BOE date from the PDF url, easier than parsing the expanded human readable date
      pdf = doc.search('.puntoPDF a').first.attributes['href'].value
      pdf =~ /dias\/(\d{4})\/(\d{2})\/(\d{2})/
      year, month, day = $1, $2, $3

      puts CSV::generate_line([ get_BOE_id(doc.url), 
                                "#{year}-#{month}-#{day}", 
                                department, 
                                name, 
                                sentence_date, 
                                role, 
                                crime, 
                                sentence, 
                                crime_year,
                                pardon_type,
                                pardon,
                                condition])
    end
  end
end

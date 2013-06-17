# encoding: UTF-8
# TODO: Some duplicated code below

module PardonParser
  # There are some funny non-breaking spaces in the content, we have to deal with those at some points
  NBSP = "\u00a0"
  # Vars used to point out that some handled field has been found
  @excep = false
  @excep_desc = ""

  def self.write_log(key,desc,first_part,second_part)
    $log_file.puts("#{key}: #{desc}")
    $log_file.puts("#{first_part}") if !first_part.nil?
    $log_file.puts("#{second_part}") if !second_part.nil?
  end

  def self.get_BOE_id(filename)
    filename =~ /(BOE-.-\d{4}-\d+)/
    $1
  end

  def self.get_military_trial_details(p)
    p.gsub!(NBSP, ' ') # Get rid of the funny whitespaces
    
    # Extract tribunal
    p =~ /condenad[oa] por (?:el|la) (.*?), en (?:el|las?)?\s*(?:[Dd]iligencias?|[Ss]umario|[Cc]ausa)/
    court = $1
    if $1.nil? 
      # Notify that an unhandled field has been found
      @excep_desc = "Error parsing court in get_military_trial_details"
      @excep = true
      return
    end

    # There are two alternative ways of writing the military trial details (role,crime,sentence) or (sentence,role,crime)
    # First we try the most used case (role,crime,sentence)
    p =~ /como (.*?) de (.*?), previsto y penado (?:.*?),? a las? (?:pena|medida)s? de (.*?)[,;] (?:(?:y )?(?:constando|al constar) en (?:el mismo|aqu[ée]l)|a propuesta de)/
    role, crime, sentence = $1, $2, $3
    
    if $1.nil? 
      # If we had no luck we try the second case (sentence,role,crime)
      p =~ /a las? (?:pena|medida)s? de (.*?)[,;] como (.*?) de (.*?), previsto y penado/
      sentence, role, crime = $1, $2, $3
      if $1.nil?
        # Notify that an unhandled field has been found
        @excep_desc = "Error parsing role, crime, sentence in get_military_trial_details"
        @excep = true
      end
    end
    return court, nil, role, crime, sentence, nil
  end

  def self.get_trial_details(p)
    p.gsub!(NBSP, ' ') # Get rid of the funny whitespaces

    # TODO: Handle pardons with more than one sentence date, right now catch the first one
    p =~ /condenad[ao] por (?:el|las?|los|) (.*?),? en sentencias?,? de (?:fechas? )?(\d+ de\s+[^ ]+\s+(?:de\s+)?\d{4})/
    court, sentence_date = $1, $2
    left_over = $'
    
    if $1.nil? 
      # Handle second case of court description
      #p =~ /incoad[ao] (.*) [Pp]enal,? por (?:el|la) (.*?),? en sentencias?,? de (?:fechas? )?(\d+ de\s+[^ ]+\s+(?:de\s+)?\d{4})/
      p =~ /incoad[ao] (?:.*) [Pp]enal,?(?:.* tercero,)? por (?:el|la) (.*?),? en sentencias?,? de (?:fechas? )?(\d+ de\s+[^ ]+\s+(?:de\s+)?\d{4})/
      court, sentence_date = $1, $2
      left_over = $'
      
      if $1.nil?
        # Notify that an unhandled field has been found
        @excep_desc = "Error parsing court, sentence_date in get_trial_details"
        @excep = true
        return
      end
    end
    # Restore common sentence_date Ex: 9 de septiembre 1999 -> 9 de septiembre de 1999
    parts = sentence_date.split(' ')
    if parts.length == 4
      sentence_date = [parts[0],parts[2],parts[3]].join(" de ")
    end

    # TODO: Handle pardons with more than one crime and sentence, right now after first crime
    # the rest is stored inside the sentence field
    # Now get the role and crime and sentence from the remainder
    left_over =~ /como (.*?) de (.*?),? a [^ ]+ (?:medida|pena)s? ((por cada (delito|uno de ellos) )?(de )?.*?)[,;]? por hechos? cometidos?/ 
    role, crime, sentence = $1, $2, $3

    if $1.nil? 
      # Notify that an unhandled field has been found
      @excep_desc = "Error parsing role, crime and sentence in get_trial_details"
      @excep = true
      return court, sentence_date, role, crime, sentence, nil
    end

    # Get the time of the crime (trying to do this in previous regex gets messy because of many levels of brackets)
    left_over =~ /por hechos? cometidos? (?:en|durante|entre) (?:(?:el|los) años?\s*)?(\d{4}(?:\s*y\s*|\-)?(?:\d{4})?)/
    crime_year = $1

    if $1.nil?
      # In 1996 changes from year to date in the crime_year so if we don't find it in the first
      # try we parse it the second way.
      left_over =~ /por hechos? cometidos?\s*el\s*(?:\d+ de\s+[^ ]+\s+(?:de\s+)?(\d{4}))/
      crime_year = $1
      if $1.nil?
        # Notify that an unhandled field has been found
        @excep_desc = "Error parsing crime_year in get_trial_details"
        @excep = true
      end
    else
      # To give more coherence to the crime time field
      crime_year.gsub!(/\s*y\s*/,'-')
    end

    sentence.gsub!(/^de /,'') if !sentence.nil? # Remove the 'de ' at the begining, if it exists
    return court, sentence_date, role, crime, sentence, crime_year
  end
  
  def self.get_military_pardon_details(p)
    p.gsub!(NBSP, ' ') # Get rid of the funny whitespaces

    # Find out the type of perdon
    p =~ /^\s*Vengo\s+(?:en|a)\s+(?:.*),? el (.*?) (?:respecto )?(?:de|a) las? (?:medida|pena)s?/
    pardon_type = $1
    left_over = $'

    if $1.nil?
      # Notify that an unhandled field has been found
      @excep_desc = "Error parsing pardon_type in get_military_pardon_details"
      @excep = true
      return
    end
    
    # Get some more details based on the pardon_type
    if (pardon_type != 'indulto total' )
      # Find out what the new sentence is
      left_over =~ /(?:remitiendo|que remitirá)\s+(?:.*?)\s*(?:a|por|hasta) la (?:pena\s*)?de (.*?)\./
      new_sentence = $1
    
      if $1.nil? 
        # Notify that an unhandled field has been found
        @excep_desc = "Error parsing new_sentence in get_military_pardon_details"
        @excep = true
      else
        # Clean up new_sentence in case name appears in
        if (new_sentence =~ /((don|doña)( ((y)|(de la)|(de los)|del|de|[A-ZÁÉÍÓÚ][^ ]+))+)/)
          new_sentence.gsub!(/prisión, al? .*$/,"prisión.")
        end
        
      end
      
    end

    return pardon_type, new_sentence, nil
  end

  def self.get_pardon_details(p)
    p.gsub!(NBSP, ' ') # Get rid of the funny whitespaces

    # Find out the type of perdon
    p =~ /^\s*Vengo (?:en|a) (?:conceder )?(\w+) (?:a|las?)/
    pardon_type = $1
    left_over = $'
    
    if $1.nil? 
      # Notify that an unhandled field has been found
      @excep_desc = "Error parsing pardon_type in get_pardon_details"
      @excep = true
      return
    end

    # Get some more details based on the pardon_type
    if ( pardon_type == 'conmutar' )
      # Note: ?: is a non-capturing group
      left_over =~ / por(?: otra(?: única)? de)? (.*?),? a condición (?:de )que (.*?)(:? desde la publicación|\.\s+Dado)/
      new_sentence, condition = $1, $2
      if $1.nil? 
        # Notify that an unhandled field has been found
        @excep_desc = "Error parsing new_sentence and condition in get_pardon_details"
        @excep = true
      end
      return pardon_type, new_sentence, condition
    else
      left_over =~ /^ (.*?),? a condición (?:de )que (.*?)(:? desde la publicación|\.\s+Dado)/
      partial_pardon, condition = $1, $2
      if $1.nil? 
        # Notify that an unhandled field has been found
        @excep_desc = "Error parsing partial_pardon and condition in get_pardon_details"
        @excep = true
      else
        # If condition starts with don/doña remove the name from the partial_pardon
        partial_pardon.gsub!(/^\s*(don|doña)( ((y)|(de la)|(de los)|del|de|[A-ZÁÉÍÓÚ][^ ]+))+\s*/,'')
      end
      return pardon_type, partial_pardon, condition
    end
  end
  
  def self.get_pardon_authorization_details(p)
    p.gsub!(NBSP, ' ') # Get rid of the funny whitespaces

    # Find out the pardon authorization date
    p =~ /\s*Dado en (?:.*?)(?:el|a)\s*(\d+\s*de\s*[^ ]+\s+(?:de\s+)?\d{4})\.?/
    pardon_date = $1
    left_over = $'

    if $1.nil?
      # Notify that an unhandled field has been found
      @excep_desc = "Error parsing pardon_date in get_pardon_authorization_details"
      @excep = true
      return
    end
    
    # Find out the pardon authorization minister
    left_over =~ /\s*(?:El|La)\s*Ministr[oa] (?:.*?)[,\.]\s*(.*)\s*$/
    minister = $1
    
    if $1.nil?
      @excep_desc = "Error parsing minister in get_pardon_authorization_details"
      @excep = true
      return pardon_date, nil
    else
      minister.gsub!(/\s*$/,"")
    end
    
    return pardon_date, minister
  end

  def self.parse_file(doc)
    # Initialize exception vars
    @excep = false
    @excep_desc = ""
    title = doc.css("h3.documento-tit").text.squeeze(" ")
   
    # Find out whether we have a pardon. Don't try to match the name in the title just in case, 
    # we're being very prudent here to avoid missing a pardon.
    if (!title.empty? and (title =~ /se indulta al? / or title =~ /se concede el indulto,? /))
      # Register in the log and ignore the document if it is an error correction document
      if (title =~ /^Corrección/)
        write_log(get_BOE_id(doc.url),"Is a correction statement review",nil,nil)
        return
      end
      
      # Get main details from document...
      #Department
      department = doc.css("p.valDoc")[2].text
      
      # First we capture all the text paragraphs 
      pardon_text = doc.css("div#textoxslt").text
      # Format the obtained text to unify it
      formatted_text = pardon_text.gsub(/\n/,"").gsub(/\t/, ' ').squeeze(" ")
      # Split the text in two groups trial and pardon details: 
      #We have to capture all these cases Ex: BOE-A-2004-10243 , BOE-A-2007-17870 and BOE-A-2009-2130
      parts = formatted_text.split(/(?:\s*Vengo (?:en|a)|[Oo]\s*:)/)
      # Having detected the splitting point compose the two paragraphs
      # in other case write to log to check unhandled cases.
      if parts.length > 1
        first_paragraph = parts[0]
        second_paragraph = "Vengo en" + parts[1]
      else
        write_log(get_BOE_id(doc.url),"Unknown pardon text structure",formatted_text,nil)
        return;
      end

      puts "#{get_BOE_id(doc.url)},\"#{title}\",\"#{first_paragraph.strip}\",\"#{second_paragraph.strip}\""

      if department == 'Ministerio de Defensa'
        court, sentence_date, role, crime, sentence, crime_year = get_military_trial_details(first_paragraph)
        pardon_type, pardon, condition = get_military_pardon_details(second_paragraph)
      else
        court, sentence_date, role, crime, sentence, crime_year = get_trial_details(first_paragraph)
        pardon_type, pardon, condition = get_pardon_details(second_paragraph)
      end
      pardon_date, minister = get_pardon_authorization_details(second_paragraph)
      
      # Gender
      title =~ /([Dd]on|[Dd]oña)/
      gender = $1
      if $1.nil?
        @excep = true
        write_log(get_BOE_id(doc.url),"Error parsing gender in parse_file",title,formatted_text)
        return
      else
        if gender.index("ñ")
          gender = "M"
        else
          gender = "H"
        end
      end   
      
      #BOE date
      # We get the BOE date from the PDF url, easier than parsing the expanded human readable date
      # We can only assume that the class startsWith puntoPDF since it changes to puntoPDFsup in earlier years.
      pdf = doc.xpath('//li[starts-with(@class, "puntoPDF")]/a').first.attributes['href'].value
      pdf =~ /dias\/(\d{4})\/(\d{2})\/(\d{2})/
      year, month, day = $1, $2, $3
      
      if $1.nil? 
        @excep = true
        write_log(get_BOE_id(doc.url),"Error parsing BOE_DATE in parse_file",pdf,formatted_text)
        return
      end
      
      if @excep
        # Having found an exception during parsing log error data and write this pardon statement to the debug file
        write_log(get_BOE_id(doc.url),@excep_desc, first_paragraph, second_paragraph)
        $output_debug_file.puts CSV::generate_line([ get_BOE_id(doc.url), 
                                "#{year}-#{month}-#{day}", 
                                department, 
                                gender,
                                court, 
                                sentence_date, 
                                role, 
                                crime, 
                                nil,
                                sentence, 
                                crime_year,
                                pardon_type,
                                pardon,
                                condition,
                                pardon_date,
                                minister])
        return false
      else
        # Write to output file
        $output_file.puts CSV::generate_line([ get_BOE_id(doc.url), 
                                "#{year}-#{month}-#{day}", 
                                department, 
                                gender, 
                                court,
                                sentence_date, 
                                role, 
                                crime, 
                                nil,
                                sentence, 
                                crime_year,
                                pardon_type,
                                pardon,
                                condition,
                                pardon_date,
                                minister])
        return true
      end
    end
  end
end

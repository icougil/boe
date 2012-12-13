# encoding: UTF-8

# Sample data:
#   - civilian pardon: http://www.boe.es/buscar/doc.php?id=BOE-A-2012-14763
#   - military pardon: http://www.boe.es/buscar/doc.php?id=BOE-A-2012-13810

require 'test/unit'
require './lib/PardonParser.rb'

class PardonParserTest < Test::Unit::TestCase

  def test_first_paragraph_parsing
    aMalePardon = "Visto el expediente de indulto de don Un Hombre Cualquiera, condenado por el Juzgado de lo Penal número 3 de Sabadell, en sentencia de 13 de mayo de 2009, como autor de cuatro delitos de robo con fuerza en las cosas, a la pena por cada delito de un año de prisión, con la accesoria de inhabilitación especial del derecho de sufragio pasivo durante el tiempo de la condena, por hechos cometidos en el año 2004, en el que se han considerado los informes del Tribunal sentenciador y del Ministerio Fiscal, a propuesta del Ministro de Justicia y previa deliberación del Consejo de Ministros en su reunión del día 13 de julio de 2012,"
    court, date, role, crime, sentence, crime_year = PardonParser.get_trial_details(aMalePardon)
    assert_equal "Juzgado de lo Penal número 3 de Sabadell", court
    assert_equal "13 de mayo de 2009", date
    assert_equal "autor", role
    assert_equal "cuatro delitos de robo con fuerza en las cosas", crime
    assert_equal "por cada delito de un año de prisión, con la accesoria de inhabilitación especial del derecho de sufragio pasivo durante el tiempo de la condena", sentence
    assert_equal "2004", crime_year

    aFemalePardon = "Visto el expediente de indulto de doña Una Mujer Cualquiera, condenada por la Audiencia Provincial de Madrid, sección quinta, en sentencia de 21 de septiembre de 2010, como autora de un delito de falsedad documental, a la pena de tres años de prisión, multa de seis meses con una cuota diaria de seis euros, e inhabilitación especial para el derecho de sufragio público durante el tiempo de la condena e inhabilitación especial para el empleo público que desempeñaba por tiempo de dos años, por hechos cometidos en el año 2007, en el que se han considerado los informes del Tribunal sentenciador y del Ministerio Fiscal, a propuesta del Ministro de Justicia y previa deliberación del Consejo de Ministros en su reunión del día 24 de agosto de 2012,"
    court, date, role, crime, sentence, crime_year = PardonParser.get_trial_details(aFemalePardon)
    assert_equal "Audiencia Provincial de Madrid, sección quinta", court
    assert_equal "21 de septiembre de 2010", date
    assert_equal "autora", role
    assert_equal "un delito de falsedad documental", crime
    assert_equal "tres años de prisión, multa de seis meses con una cuota diaria de seis euros, e inhabilitación especial para el derecho de sufragio público durante el tiempo de la condena e inhabilitación especial para el empleo público que desempeñaba por tiempo de dos años", sentence
    assert_equal "2007", crime_year

    anotherPardon = "Visto el expediente de indulto de don Otro Hombre, condenado por el Juzgado de lo Penal número 2 de Bilbao, en sentencia de 14 de marzo de 2011, como autor de dos delitos de lesiones con uso de instrumento peligroso, a la pena por cada uno de ellos de dos años de prisión e inhabilitación especial para el derecho de sufragio pasivo durante el tiempo de la condena, por hechos cometidos en el año 2009, en el que se han considerado los informes del Tribunal sentenciador y del Ministerio Fiscal, a propuesta del Ministro de Justicia y previa deliberación del Consejo de Ministros en su reunión del día 20 de julio de 2012,"
    court, date, role, crime, sentence, crime_year = PardonParser.get_trial_details(anotherPardon)
    assert_equal "Juzgado de lo Penal número 2 de Bilbao", court
    assert_equal "14 de marzo de 2011", date
    assert_equal "autor", role
    assert_equal "dos delitos de lesiones con uso de instrumento peligroso", crime
    assert_equal "por cada uno de ellos de dos años de prisión e inhabilitación especial para el derecho de sufragio pasivo durante el tiempo de la condena", sentence
    assert_equal "2009", crime_year

    multipleCharges = "Visto el expediente de indulto de don Otra Persona, condenado por la Audiencia Provincial de Ourense, sección segunda, en sentencia de 4 de febrero de 2011, como autor de un delito de detención ilegal y de una falta de lesiones, a las penas de un año de prisión y cuatro años de inhabilitación absoluta, por el primero y a la de multa de un mes con una cuota diaria de seis euros, por la segunda, por hechos cometidos en el año 2006, en el que se han considerado los informes del Tribunal sentenciador y del Ministerio Fiscal, a propuesta del Ministro de Justicia y previa deliberación del Consejo de Ministros en su reunión del día 25 de mayo de 2012,"
    court, date, role, crime, sentence, crime_year = PardonParser.get_trial_details(multipleCharges)
    assert_equal "Audiencia Provincial de Ourense, sección segunda", court
    assert_equal "4 de febrero de 2011", date
    assert_equal "autor", role
    assert_equal "un delito de detención ilegal y de una falta de lesiones", crime
    assert_equal "un año de prisión y cuatro años de inhabilitación absoluta, por el primero y a la de multa de un mes con una cuota diaria de seis euros, por la segunda", sentence
    assert_equal "2006", crime_year
  end

  def test_military_first_paragraph
    aMilitaryPardon = "Visto el expediente de indulto relativo al Soldado Militar Profesional de Tropa y Marinería del Ejército de Tierra don Rubén Pariente González, condenado por el Tribunal Militar Territorial Primero, con sede en Madrid, en las Diligencias Preparatorias número 12/35/07, como autor de un delito de «deserción», previsto y penado en el artículo 120 del Código Penal Militar, a la pena de dos años y cuatro meses de prisión, con las accesorias legales de suspensión de cargo público y derecho de sufragio pasivo durante el tiempo de la condena, constando en el mismo los informes del Tribunal Sentenciador, del Fiscal Jurídico Militar y del Asesor Jurídico General del Ministerio de Defensa, a propuesta del Ministro de Defensa y previa deliberación del Consejo de Ministros en su reunión del día 5 de octubre de 2012,"
    court, sentence_date, role, crime, sentence, crime_year = PardonParser.get_military_trial_details(aMilitaryPardon)
    assert_equal "Tribunal Militar Territorial Primero, con sede en Madrid", court
    assert_equal nil, sentence_date
    assert_equal "autor", role
    assert_equal "un delito de «deserción», previsto y penado en el artículo 120 del Código Penal Militar", crime
    assert_equal "dos años y cuatro meses de prisión, con las accesorias legales de suspensión de cargo público y derecho de sufragio pasivo durante el tiempo de la condena", sentence
    assert_equal nil, crime_year

    secondHalf = "Vengo en conceder al Soldado Militar Profesional de Tropa y Marinería del Ejército de Tierra don Rubén Pariente González, el indulto parcial respecto de la pena de prisión impuesta con sus accesorias legales, remitiendo la misma por la de seis meses de prisión con sus accesorias legales."
    pardon_type, name, new_sentence, condition = PardonParser.get_military_pardon_details(secondHalf)
    assert_equal 'indulto parcial', pardon_type
    assert_equal 'don Rubén Pariente González', name
    assert_equal 'seis meses de prisión con sus accesorias legales', new_sentence
    assert_equal nil, condition
  end

  def test_second_paragraph_parsing
    aSentenceCommute = "Vengo en conmutar a don Hombre Cualquiera la pena privativa de libertad impuesta por otra de dos años de prisión a condición de que no abandone el tratamiento iniciado hasta alcanzar la total rehabilitación y no vuelva a cometer delito doloso en el plazo de tres años desde la publicación del real decreto."
    pardon_type, name, new_sentence, condition = PardonParser.get_pardon_details(aSentenceCommute)
    assert_equal 'conmutar', pardon_type
    assert_equal 'don Hombre Cualquiera', name
    assert_equal 'dos años de prisión', new_sentence
    assert_equal 'no abandone el tratamiento iniciado hasta alcanzar la total rehabilitación y no vuelva a cometer delito doloso en el plazo de tres años', condition

    multipleCommutes = "Vengo en conmutar a don Hombre Cualquiera de García todas las penas privativas de libertad impuestas por otra única de dos años de prisión, a condición de que no vuelva a cometer delito doloso en el plazo de cuatro años desde la publicación del real decreto."
    pardon_type, name, new_sentence, condition = PardonParser.get_pardon_details(multipleCommutes)
    assert_equal 'conmutar', pardon_type
    assert_equal 'don Hombre Cualquiera de García', name
    assert_equal 'dos años de prisión', new_sentence
    assert_equal 'no vuelva a cometer delito doloso en el plazo de cuatro años', condition

    aPartialPardon = "Vengo en indultar a don Hombre Cualquiera de la Fuente seis meses de la pena privativa de libertad impuesta, a condición de que no vuelva a cometer delito doloso en el plazo de tres años desde la publicación del real decreto."
    pardon_type, name, partial_pardon, condition = PardonParser.get_pardon_details(aPartialPardon)
    assert_equal 'indultar', pardon_type
    assert_equal 'don Hombre Cualquiera de la Fuente', name
    assert_equal 'seis meses de la pena privativa de libertad impuesta', partial_pardon
    assert_equal 'no vuelva a cometer delito doloso en el plazo de tres años', condition

    multiplePardons = "Vengo en indultar a don Hombre Cualquiera las penas privativas de libertad pendientes de cumplimiento a condición de que no vuelva a cometer delito doloso en el plazo de tres años desde la publicación del real decreto."
    pardon_type, name, partial_pardon, condition = PardonParser.get_pardon_details(multiplePardons)
    assert_equal 'indultar', pardon_type
    assert_equal 'don Hombre Cualquiera', name
    assert_equal 'las penas privativas de libertad pendientes de cumplimiento', partial_pardon
    assert_equal 'no vuelva a cometer delito doloso en el plazo de tres años', condition

    communityWork = "Vengo en conmutar a don Hombre Cualquiera las penas privativas de libertad y de multa impuestas por 30 días de trabajo en beneficio de la comunidad, a condición de que no vuelva a cometer delito doloso en el plazo de tres años desde la publicación del real decreto."
    pardon_type, name, new_sentence, condition = PardonParser.get_pardon_details(communityWork)
    assert_equal 'conmutar', pardon_type
    assert_equal 'don Hombre Cualquiera', name
    assert_equal '30 días de trabajo en beneficio de la comunidad', new_sentence
    assert_equal 'no vuelva a cometer delito doloso en el plazo de tres años', condition
  end
end
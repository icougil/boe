# encoding: UTF-8

require 'test/unit'
require './parse.rb'

class PardonParserTest < Test::Unit::TestCase

  AMalePardon = "Visto el expediente de indulto de don Un Hombre Cualquiera, condenado por el Juzgado de lo Penal número 3 de Sabadell, en sentencia de 13 de mayo de 2009, como autor de cuatro delitos de robo con fuerza en las cosas, a la pena por cada delito de un año de prisión, con la accesoria de inhabilitación especial del derecho de sufragio pasivo durante el tiempo de la condena, por hechos cometidos en el año 2004, en el que se han considerado los informes del Tribunal sentenciador y del Ministerio Fiscal, a propuesta del Ministro de Justicia y previa deliberación del Consejo de Ministros en su reunión del día 13 de julio de 2012,"
  AFemalePardon = "Visto el expediente de indulto de doña Una Mujer Cualquiera, condenada por la Audiencia Provincial de Madrid, sección quinta, en sentencia de 21 de septiembre de 2010, como autora de un delito de falsedad documental, a la pena de tres años de prisión, multa de seis meses con una cuota diaria de seis euros, e inhabilitación especial para el derecho de sufragio público durante el tiempo de la condena e inhabilitación especial para el empleo público que desempeñaba por tiempo de dos años, por hechos cometidos en el año 2007, en el que se han considerado los informes del Tribunal sentenciador y del Ministerio Fiscal, a propuesta del Ministro de Justicia y previa deliberación del Consejo de Ministros en su reunión del día 24 de agosto de 2012,"
  AMilitaryPardon = "Visto el expediente de indulto relativo al Soldado Militar Profesional de Tropa y Marinería del Ejército de Tierra don Un Soldado Cualquiera, condenado por el Tribunal Militar Territorial Primero, con sede en Madrid, en las Diligencia Preparatorias número 11/260/06, como autor de un delito de «deserción», previsto y penado en el artículo 120 del Código Penal Militar, a la pena de dos años y cuatro meses de prisión, con las accesorias legales de suspensión de cargo público y derecho de sufragio pasivo durante el tiempo de la condena, constando en el mismo los informes del Tribunal Sentenciador, del Fiscal Jurídico Militar y del Asesor Jurídico General del Ministerio de Defensa, a propuesta del Ministro de Defensa y previa deliberación del Consejo de Ministros en su reunión del día 3 de agosto de 2012,"

  def test_date_extraction
    assert_equal "13 de mayo de 2009", PardonParser.get_trial_details(AMalePardon)
    assert_equal "21 de septiembre de 2010", PardonParser.get_trial_details(AFemalePardon)
    assert_equal nil, PardonParser.get_trial_details(AMilitaryPardon)
  end
end
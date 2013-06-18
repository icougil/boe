# encoding: UTF-8

module GreenCardParser
  def self.get_BOE_id(filename)
    filename =~ /(BOE-.-\d{4}-\d+)/
    $1
  end

  def self.parse_file(doc)
    title = doc.css("h3.documento-tit").text.squeeze(" ")

    # Find out whether we have a green card. Don't try to match the name in the title just in case, 
    # we're being very prudent here to avoid missing a green card.
    if (!title.empty? and title =~ /carta de naturaleza/)
      green_card = { :boe_id => get_BOE_id(doc.url) }

      title =~ /Real Decreto (\d+)\/(\d+),?(?: de)? ([\d a-zA-Z]+),/
      green_card[:decree_id] = $1
      green_card[:year] = $2
      green_card[:date] = $3

      title =~ /(don|doña) (.*?)\.?$/
      green_card[:gender] = $1
      green_card[:name] = $2

      return green_card
    end
  end
end

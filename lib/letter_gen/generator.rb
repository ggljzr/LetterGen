require 'fileutils'
require 'json'

# Class for generating .tex files from templates and form input
class LetterGenerator
  ROOT_PATH = File.dirname(__FILE__).freeze
  TEMPLATE_PATH = "#{ROOT_PATH}/templates/letter_template.tex".freeze
  LETTER_CLASS_PATH = "#{ROOT_PATH}/templates/myletter.cls".freeze
  TARGET_PATH = 'letters'.freeze
  PARA_PATH = "#{ROOT_PATH}/templates/paragraphs.json".freeze

  def initialize(secretary_dict, company_dict, gov_dict, user_dict, dates_dict)
    @gen_data = {}
    @gen_data = @gen_data.merge(secretary_dict)
    @gen_data = @gen_data.merge(company_dict)
    @gen_data = @gen_data.merge(gov_dict)
    @gen_data = @gen_data.merge(user_dict)
    @gen_data = @gen_data.merge(dates_dict)

    File.open(TEMPLATE_PATH, 'r') do |f|
      @template_text = f.read
    end
  end

  def generate_letter(letter_name, paragraph)
    letter_text = @template_text
    @gen_data.each do |key, value|
      letter_text = letter_text.gsub("$#{key}$", value.to_s)
    end

    letter_text = letter_text.gsub('$paragraph$', paragraph)

    FileUtils.mkdir_p("#{TARGET_PATH}/#{letter_name}")
    File.open("#{TARGET_PATH}/#{letter_name}/#{letter_name}.tex", 'w') { |f| f.write(letter_text) }
  end

  def generate
    FileUtils.mkdir_p("#{TARGET_PATH}/static")
    FileUtils.cp("#{LETTER_CLASS_PATH}", "#{TARGET_PATH}/static")

    paragraphs = File.open(PARA_PATH, 'r') { |f| f.read }
    paragraphs = JSON.parse(paragraphs)

    paragraphs.each { |para| generate_letter(para['name'], para['text'])}

  end
end

require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

before do
  @contents = File.readlines("data/toc.txt")
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"

  erb :home
end


get "/chapters/:number" do
  number = params[:number].to_i
  chapter_name = @contents[number - 1]

  redirect "/" unless (1..@contents.size).cover? number

  @title = "Chapter #{number}: #{chapter_name}"
  @chapter = in_paragraphs(File.read("data/chp#{number}.txt"))

  erb :chapter
end

get "/search" do
  @query = params['query']
  @chapter_matches = []
  counter = 1
  unless @query == nil
    until counter == @contents.size
      text = File.read("data/chp#{counter}.txt")
      text.split("\n\n").each_with_index do |paragraph, index|
        @chapter_matches << [index, highlight_match_text(paragraph, @query), counter] if paragraph.include?(@query)
      end

      counter += 1
     end
   end

  erb :search
end

not_found do
  redirect "/#"
end

helpers do
  def in_paragraphs(text)
    text.split("\n\n").map.with_index do |paragraph, idx|
      "<p id='#{idx}'>#{paragraph}</p>"
    end.join
  end
end

helpers do
  def highlight_match_text(text, query)
    text.gsub("#{query}", "<strong>#{query}</strong>")
  end
end

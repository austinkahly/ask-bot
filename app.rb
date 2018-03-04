require "roda"
require "sequel"
require "yaml"

user = 'root'
password = 'pass'
database = 'ask-bot'

DB = Sequel.connect(YAML.load(File.read(File.join('config','database.yml')))[ENV['RACK_ENV']])
# DB = Sequel.connect(adapter: "postgres", database: database, host: "127.0.0.1", user: user, password: password)

class AskBot < Roda
  route do |r|
    r.post "save" do
      name = r["name"].downcase
      response = r["response"]

      return if name.nil? or name == "" or response.nil? or response == ""
      responses = DB[:responses]
      responses.insert(name: name, response: response)
    end

    r.get "ask" do
      if !r["id"].nil? and r["id"].to_i != 0
        puts 'a'
        resp = DB[:responses].where(name: r["id"].to_i).first
        puts resp
      else
        if !r["name"].nil? and r["name"] != ""
          responses = DB[:responses].where(name: r["name"].downcase)
        else
          responses = DB[:responses]
        end

        if responses.count == 0
          responses = DB[:responses]
        end

        resp = responses.order(Sequel.lit('RANDOM()')).limit(1)
      end
      resp = resp.map([:name, :response]).first
      "#{resp.first.capitalize} - \"#{resp.last}\""
    end

    # Returns the number of entries per person. Mainly to make sure we don't bloat the database.
    r.get "info" do
      DB[:responses].group_and_count(:name).all.to_s
    end

    r.get "list" do
      page = r["page"].to_i ||= 0
      responses = DB[:responses]
      if responses.count <= page * 20 || page == 0
        responses.limit(20, page * 20).map([:id, :name, :response]).to_s
      end
    end

    r.post "seed_database" do
      responses = DB[:responses]
      data_to_seed = ["How can I smell my feet if they are in your mouth?", "I like green apples because they make me horny", "You mean they have a better change of being frogged checked", "Terabytes, they are like the modern day ram. Dodge Ram not computer ram.", "You tasty little poptart", "You're in timeout mr."]

      # Don't seed twice.):
      if responses.where(response: data_to_seed.first) == nil
        data_to_seed.each do |msg|
          responses.insert(name: "kevin", response: msg)
        end
      end
    end
  end
end
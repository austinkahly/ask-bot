require "roda"
require "sequel"

if ENV['RACK_ENV'] == 'production'
  DB = Sequel.connect(ENV['DATABASE_URL'])
else
  user = 'root'
  password = 'pass'
  database = 'ask-bot'
  DB = Sequel.connect(adapter: "postgres", database: database, host: "127.0.0.1", user: user, password: password)
end


class AskBot < Roda
  route do |r|
    r.on "save" do
      name = r["name"].downcase
      response = r["response"]

      return if name.nil? or name == "" or response.nil? or response == ""
      responses = DB[:responses]
      responses.insert(name: name, response: response)
    end

    r.on "help" do
      {
        "response_type": "in_channel",
        "text": "Use /ask add <name> <quote> to add new quotes."
      }.to_json
    end

    r.on "ask" do
      if !r["id"].nil? and r["id"].to_i != 0
        resp = DB[:responses].where(id: r["id"].to_i)
      else
        # If this returns none, maybe throw an error that they need to add
        # something for that person?
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
      if resp.count == 0
        {
          "response_type": "in_channel",
          "text": "Start quoting people to get responses."
        }.to_json

      else
        resp = resp.map([:name, :response]).first
        {
          "response_type": "in_channel",
          "text": "#{resp.first.capitalize} - \"#{resp.last}\"",
          "mrkdwn": true
        }.to_json
      end
    end

    # Returns the number of entries per person. Mainly to make sure we don't bloat the database.
    r.on "info" do
      DB[:responses].group_and_count(:name).all.to_s
    end

    r.on "list" do
      page = r["page"].to_i ||= 0
      responses = DB[:responses]
      if responses.count <= page * 20 || page == 0
        {
          "response_type": "in_channel",
          "text": "Page #{page}\n#{responses.limit(20, page * 20).map([:id, :name, :response]).join("\n")}",
          "mrkdwn": true
        }.to_json
      end
    end
  end
end
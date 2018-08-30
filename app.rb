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
  plugin :json

  route do |r|
    r.on "shibe" do
      url = open("http://shibe.online/api/shibes").read.gsub("[\"", "").gsub("\"]", "")

      response['Content-Type'] = 'application/json'
      message = {
        response_type: "in_channel",
        attachments: [
          {
            fallback: ":cool-doge:",
            color: "#36a64f",
            title_link: "Shibe",
            fields: [],
            image_url: url,
            thumb_url: url,
            ts: Time.now.to_i
          }
        ]
      }
      message.to_json
    end

    r.on "help" do
      {
        text: "Use /ask add <name> <quote> to add new quotes."
      }
    end

    r.on "delete" do
      id = r["id"].to_i
      deleted = DB[:responses].where(id: id).delete
      if deleted == 1
        "Deleted successfully"
      else
        "An error occurred"
      end
    end

    r.on "ask" do
      if r["text"] != "" and r["text"] != nil
        command = r["text"].split(' ').first

        if command == "add"
          save_new_record(r["text"])
        else
          responses = DB[:responses].where(name: command.downcase)
          if responses.count == 0
            {
              text: "No responses found for #{command}."
            }
          else
            resp = responses.order(Sequel.lit('RANDOM()')).limit(1).first
            {
              response_type: "in_channel",
              text: "#{resp[:name].capitalize} - \"#{resp[:response]}\"",
              mrkdwn: true
            }
          end
        end
      else
        responses = DB[:responses]
        if responses.count == 0
          {
            text: "Start quoting people using /ask add <name> <quote> to get responses."
          }
        else
          resp = responses.order(Sequel.lit('RANDOM()')).limit(1).first
          {
            response_type: "in_channel",
            text: "#{resp[:name].capitalize} - \"#{resp[:response]}\"",
            mrkdwn: true
          }
        end
      end
    end

    # Returns the number of entries per person. Mainly to make sure we don't bloat the database.
    r.on "info" do
      DB[:responses].group_and_count(:name).all.to_s
    end

    r.on "list" do
      # page = r["page"].to_i ||= 0
      responses = DB[:responses]
      # if responses.count <= page * 20 || page == 0
      #   "Page #{page}\n#{responses.limit(20, page * 20).map([:id, :name, :response]).join("\r\n")}"
      # end
      responses.map([:id, :name, :response])
    end
  end

  def save_new_record(params)
    params = params.split(' ')
    if params.count <= 1
      {
        text: "Invalid number of parameters. Please use /ask add <name> <message>"
      }
    else
      command = params.shift # add
      name = params.shift
      response = params.join(' ')

      responses = DB[:responses]

      dup = responses.where(name: name.downcase, response: response)
      if dup.count != 0
        {
          text: "Response #{response} already exists for #{name}"
        }
      else
        id = responses.insert(name: name.downcase, response: response)
        {
          text: "Added #{response} to #{name} @ id #{id}"
        }
      end
    end
  end
end
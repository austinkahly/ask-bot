require "roda"
require "sequel"

database = "myapp_development"
user     = 'root'
password = 'pass'
DB = Sequel.connect(adapter: "postgres", database: database, host: "127.0.0.1", user: user, password: password)

class App < Roda
  route do |r|
    r.post "save" do
      name = r["name"].downcase
      response = r["response"]
      question = r["question"]

      return if name.nil? or name == "" or response.nil? or response == ""
      responses = DB[:responses]
      responses.insert(name: name, response: response, question: question)
    end

    r.get "ask" do
      responses = DB[:responses].where(name: r["name"].downcase)
      resp = responses.order(Sequel.lit('RANDOM()')).limit(1)
      resp.map(:response).first.to_s
    end

    r.post "seed_database" do
      responses = DB[:responses]
      ["How can I smell my feet if they are in your mouth?", "I like green apples because they make me horny", "You mean they have a better change of being frogged checked", "Terabytes, they are like the modern day ram. Dodge Ram not computer ram.", "You tasty little poptart", "You're in timeout mr."].each do |msg|
        responses.insert(name: "kevin", response: msg)
      end
    end
  end
end
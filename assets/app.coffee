#= require config
#= require payload

rest = require 'restler'
express = require 'express'

app = express()
app.use express.json()

app.post '/', (req, res) ->
  res.send {}
  @project = req.body.repository.name
  @commits = req.body.commits
  getCards()


getCards = ->
  board = getBoard()
  url = "#{config.trello.api}/boards/#{board}/cards/?key=#{config.trello.key}&token=#{config.trello.token}"
  rest.get(url).on 'complete', (data) =>
    @cards = data
    parseCommit commit for commit in @commits


getBoard = ->
  for project in config.projects
    return project.boardId if project.name is @project


parseCommit = (commit) ->
  num = parseInt(commit.message.match(/^#([0-9]+)/)[1], 10)
  for card in @cards
    shortLink = card.shortLink if card.idShort is num
  addComment shortLink, commit.url


addComment = (id, msg) ->
  url = "#{config.trello.api}/cards/#{id}/actions/comments?key=#{config.trello.key}&token=#{config.trello.token}"
  rest.post(url,
    data:
      text: msg
  ).on 'complete', (data, response) ->
    console.log '200 ok' if (response.statusCode == 201)
    return

app.listen 4567, ->
  console.log 'Listening on port 4567'

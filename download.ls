require! <[ request cheerio fs async csv-parser ]>
origin = \http://www.reginfo.gov

fs.mkdir-sync 'xml' unless fs.exists-sync 'xml'
fs.unlink-sync 'download.log' if fs.exists-sync 'download.log'
fs.append-file-sync 'download.log', "========== #{new Date!} started ==========\n"

function get-link (rin)
  err, res, body <- request.get "http://www.reginfo.gov/public/do/eAgendaViewRule?pubId=null&RIN=#{rin}"
  $ = cheerio.load body
  links = ($ '.pageSubNavTxt' .map (,it) -> origin + $ it .attr \href).to-array!
  if links.length > 0
    download-file links.0
    fs.append-file-sync 'download.log', "#{rin} downloaded.\n"
  else
    fs.append-file-sync 'download.log', "#{rin} not published.\n"

function download-file (url)
  rin = url.match /.+RIN=(.+)/ .1
  err, res, body <- request.get url
  $ = cheerio.load body

  link = origin + $ '.pageSubNav' .eq 2 .attr 'href'
  request.get link .pipe fs.createWriteStream 'xml/' + rin + '.xml'


tasks = []

end = ->
  i = -50
  setInterval ->
    i += 50
    console.log i
    err, results <- async.series tasks.slice i, i+50
    console.log results.length + " items done."
  , 60000

data <- fs.createReadStream '1983-2013 all 2.csv' .pipe csv-parser! .on 'end' end .on \data
tasks.push (next) ->
  get-link data['/REGACT/RIN']
  next null, 'done'

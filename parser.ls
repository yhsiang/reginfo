require! <[ fs ]>
{ parse-string } = require 'xml2js'

xml = fs.read-file-sync 'xml/0348-AB56.xml', 'utf8'

err, result <- parse-string xml

output-string = ''

root = result['REGINFO_RIN_DATA']['RIN_INFO'][0]

abstract = root['ABSTRACT'][0]
agency = root['AGENCY'][0]
agency-code = agency['CODE'][0]
agency-name = agency['NAME'][0]
agency-acronym = agency['ACRONYM'][0]

output-string += "#{abstract},#{agency-code},#{agency-name},"

contact = root['AGENCY_CONTACT_LIST'][0]['CONTACT'][0]
contact-agency-acronym = contact['AGENCY'][0]['ACRONYM'][0]
contact-agency-code = contact['AGENCY'][0]['CODE'][0]
contact-agency-name = contact['AGENCY'][0]['NAME'][0]

output-string += "#{contact-agency-acronym},#{contact-agency-code},#{contact-agency-name},"
# contacts = root['AGENCY_CONTACT_LIST'][0]['CONTACT']
# contacts-agency-code = contacts.map -> it['AGENCY'][0]['CODE'][0]
# contacts-agency-acronym = contacts.map ->
#   return it['AGENCY'][0]['ACRONYM'][0] if it['AGENCY'][0]['ACRONYM']
#   ''
# contacts-agency-name = contacts.map ->
#   return it['AGENCY'][0]['NAME'][0] if it['AGENCY'][0]['NAME']
#   ''

govt-levels = root['GOVT_LEVEL_LIST'][0]['GOVT_LEVEL']

govt-levels.map -> output-string += "#{it},"
interest = root['INTERNATIONAL_INTEREST'][0]
output-string += "#{interest},"

dline-type = dline-action-stage = dline-date = dline-desc = ''

if root['LEGAL_DLINE_LIST']
  legal-dline-info = root['LEGAL_DLINE_LIST'][0]['LEGAL_DLINE_INFO'][0]
  dline-type = legal-dline-info['DLINE_TYPE'][0]
  dline-action-stage = legal-dline-info['DLINE_ACTION_STAGE'][0]
  dline-date = legal-dline-info['DLINE_DATE'][0]
  dline-desc = legal-dline-info['DLINE_DESC'][0]

output-string += "#{dline-type},#{dline-action-stage},#{dline-date},#{dline-desc},"
parent-agency-code = parent-agency-name = parent-agency-acronym = ''

if root['PARENT_AGENCY']
  parent-agency-code = root['PARENT_AGENCY'][0]['CODE'][0]
  parent-agency-name = root['PARENT_AGENCY'][0]['NAME'][0]
  parent-agency-acronym = root['PARENT_AGENCY'][0]['ACRONYM'][0]

publication-id = root['PUBLICATION'][0]['PUBLICATION_ID'][0]
publication-title = root['PUBLICATION'][0]['PUBLICATION_TITLE'][0]

output-string += "#{publication-id},#{publication-title},"

rfa-required = root['RFA_REQUIRED'][0]
rin = root['RIN'][0]
rin-status = root['RIN_STATUS'][0]
output-string += "#{rfa-required},#{rin},#{rin-status},"

rplan-entry = root['RPLAN_ENTRY'][0]
rule-stage = root['RULE_STAGE'][0]
rule-title = root['RULE_TITLE'][0]
output-string += "#{rplan-entry},#{rule-stage},#{rule-title},"
sic-desc = ''
sic-desc = root['SIC_DESC'][0] if root['SIC_DESC']

output-string += "#{sic-desc},"

timetables = root['TIMETABLE_LIST'][0]['TIMETABLE']

timetables.map -> output-string += "#{it['TTBL_ACTION'][0]},#{it['TTBL_DATE'][0]},"
#actions = timetables.map -> it['TTBL_ACTION'][0]
#dates = timetables.map -> it['TTBL_DATE'][0]

fs.append-file-sync 'output.csv', output-string




moment = require 'moment'

Date::format = -> moment(@).format(arguments...)

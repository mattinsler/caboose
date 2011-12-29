class User extends Model
  store_in 'user'
  
  static 'find_by_email', (email) ->
    @where {email: email}
  
  instance 'full_name', ->
    "#{@first_name} #{@last_name}"

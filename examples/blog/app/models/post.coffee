class Post extends Model
  store_in 'post'

  property 'name', -> "#{@first_name} #{@last_name}"

require 'date'

class MakersBnb < Sinatra::Base
  get '/spaces' do
    @properties = Property.all
    erb :'spaces/index'
  end

  post '/spaces' do
    if params[:file] != nil
      @filename = params[:file][:filename]
      file = params[:file][:tempfile]

      File.open("app/public/uploads/#{@filename}", 'wb') do |f|
        f.write(file.read)
      end
      @image_path = "/uploads/#{@filename}"
    end

    if params[:start_date] > params[:end_date]
      flash.now[:errors] = "Please enter valid dates."
      erb :'spaces/new'
    else
      property = Property.create(name: params[:name],
                                  location: params[:location],
                                  description: params[:description],
                                  price: params[:price], user_id: current_user.id, image_path: @image_path)

      if property.save
        (Date.parse(params[:start_date])..Date.parse(params[:end_date])).map(&:to_s).each do |day|
          property.days << Day.create(date: day)
        end
        property.save
        redirect '/spaces'
      else
        flash.now[:errors] = property.errors.full_messages
        erb :'spaces/new'
      end
    end
  end

  get '/spaces/new' do
    erb :'spaces/new'
  end

  get '/spaces/mylistings' do
    @user_properties = Property.all(user_id: current_user.id)
    erb :'spaces/my_listings'
  end

  get '/spaces/filter' do
    if params[:start] > params[:end]
      flash.now[:errors] = "Please enter valid dates."
      @properties = Property.all
      erb :'spaces/index'
    else
      @start_rent = params[:start]
      @end_rent = params[:end]
      chosen_dates = Filter_Dates.new
      chosen_dates.check_for_availability(params[:start], params[:end])
      @properties = chosen_dates.properties
      erb :'spaces/filter'
    end
  end
end

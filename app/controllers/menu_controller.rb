require "net/http"
require "json"

class MenuController < ApplicationController
  respond_to :xml, :html, :json
  def index

    url = "http://pixelpt-sandwich-api.herokuapp.com/sandwiches"
    resp = Net::HTTP.get_response(URI.parse(url))
    data = resp.body

    @result = JSON.parse(data)

    respond_with(@result)

  end

  def ns

    #url = "http://pixelpt-sandwich-api.herokuapp.com/sandwiches"
    url = "/sandwiches"

    @ingredients = []

    params.each do |key, value|

      Rails.logger.debug(key.to_s[0,1])

      if key.to_s[0,2] == "ig"

        if value.to_s.length > 0

          num = key.to_s[3,1]

          @ingredient = {
              "name" => value.to_s,
              "quantity" => params[:"qu_".to_s + num.to_s]
          }

          @ingredients << @ingredient

        end

      end

    end

    @san = {
        "title" => params[:sw_name],
        "price" => params[:sw_price],
        "ingredients_attributes" => @ingredients
    }

    @sandwich = {
       "sandwich" => @san
    }.to_json

    req = Net::HTTP::Post.new(url, initheader = {'Content-Type' =>'application/json'})
    req.body = @sandwich

    response = Net::HTTP.new("pixelpt-sandwich-api.herokuapp.com", 80).start {|http| http.request(req) }
    @res = "Response #{response.code} #{response.message}: #{response.body}"

    Rails.logger.debug(response.code)

    if response.code == "201"
      redirect_to root_path
    else
      respond_with(@res, @sandwich)
    end


  end

end

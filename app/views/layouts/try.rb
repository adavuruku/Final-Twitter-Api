# require 'jwt'
# payload = { data: 'test' }
# secret ='sherif'
# # IMPORTANT: set nil as password parameter
# token = JWT.encode payload, secret, 'HS256'

# # eyJhbGciOiJub25lIn0.eyJkYXRhIjoidGVzdCJ9.
# puts token
# token = "eyJhbGciOiJIUzI1NiJ9.eyJkYXRhIjoidGVzdCJ9.jQVPshQM5LwcyOOqZgaU0LQprx6HXUD5cW-kzunLXW8"
# # Set password to nil and validation to false otherwise this won't work
# decoded_token = JWT.decode token, secret, 'HS256'
# if decoded_token
#     p decoded_token
# else
#     p 'Fail'
# end
# # Array
# # [
# #   {"data"=>"test"}, # payload
# #   {"alg"=>"none"} # header
# # ]
# puts decoded_token
great = "@toy"
p great[0]
if great[0] != "@"
    p "@".concat(great)
else
    p great.index("@")
end

p "Twitter"=~ /twitter/i
test = "@oy#inda"
if (!test.match(/\A@?(\w){1,15}\Z/i) || test.match(/twitter/i) || test.match(/admin/i))
    p "Invalid"
else
    test = test[0] == "@" ? test:"@".concat(test)
    puts test
end 
h = 10 > 1 ? 2:false
p h

h = trim("rec ")
p h
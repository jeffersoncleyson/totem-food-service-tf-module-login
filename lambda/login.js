const CryptoJS = require("crypto-js");
const axios = require("axios");

const HEADER_ANONYMOUS = 'x-anonymous-user'

module.exports.handler = async (event) => {

  var username = undefined;
  var password = undefined;

  const isAnonymousRequest = event?.headers[HEADER_ANONYMOUS]?.toLowerCase() === 'true'

  if(!isAnonymousRequest){

    if(!event?.body){
      return formatResponse(
        401,
        JSON.stringify({
          messsage: "Missing request body"
        })
      );
    }
  
    const received = JSON.parse(event?.body);
    username = received?.username;
    password = received?.password;

  } else {

    username = process.env?.ANONYMOUS_USER;
    password = process.env?.ANONYMOUS_PASSWORD;
    
  }
  

  if(!username || !password){
    return formatResponse(
      401,
      JSON.stringify({
        messsage: "Missing username or password"
      })
    );
  }

  const clientId = process.env?.CLIENT_ID;
  const clientSecret = process.env?.CLIENT_SECRET;

  if(!clientId || !clientSecret || clientId == "" || clientSecret == ""){
    return formatResponse(
      500,
      JSON.stringify({
        messsage: "Contact support team"
      })
    );
  }

  const config = {
    headers: {
      "X-Amz-Target": "AWSCognitoIdentityProviderService.InitiateAuth",
      "Content-Type": "application/x-amz-json-1.1",
    },
    validateStatus: false
  };

  const body = {
    AuthParameters: {
      USERNAME: username,
      PASSWORD: password,
      SECRET_HASH: CryptoJS.enc.Base64.stringify(
        CryptoJS.HmacSHA256(username + clientId, clientSecret)
      ),
    },
    AuthFlow: "USER_PASSWORD_AUTH",
    ClientId: clientId,
  };

  const request = await axios.post(
    `https://cognito-idp.${process.env?.AWS_REGION}.amazonaws.com`,
    body,
    config
  );

  if(request.status != 200){
    return formatResponse(
      401,
      JSON.stringify({
        messsage: "Invalid username or password"
      })
    );
  }

  const data = request?.data?.AuthenticationResult;

  return formatResponse(
    200,
    JSON.stringify({
      access_token: data.AccessToken,
      expires_in: data.ExpiresIn,
      token_type: data.TokenType
    })
  )
};

var formatResponse = function(statusCode, body){
  var response = {
    "statusCode": statusCode,
    "headers": {
      "Content-Type": "application/json"
    },
    "isBase64Encoded": false,
    "body": body
  }
  return response
}
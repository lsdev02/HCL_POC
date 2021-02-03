public with sharing class EinsteinUtilityToken {
    private final String tokenEndpoint;
    private final String userNameEmail;
    private final String rsaPrivateKey;
    private final String tokenExpirationTimeInSeconds;
    
    public EinsteinUtilityToken(){
        //have to put these in custommeta data
        //and get here form metadata and then assign
        this.tokenEndpoint = 'https://api.einstein.ai/v2/oauth2/token';
        this.tokenExpirationTimeInSeconds = '3600';
        
        //have to put this in custommeta data with private-key encryption
        //and get here form metadata and then have to decrypt and then assign
        this.userNameEmail = 'razuar0031@gmail.com';
        this.rsaPrivateKey = '-----BEGIN RSA PRIVATE KEY-----'
            + 'MIIEpQIBAAKCAQEAo9S7HYZvjG54RDwU2kAM1VOgyd85Tkojna1jHIiVwHo41PgM'
            + 'zZ+3VJI8506ENl5xn6aOOsn8swAAGt1ze46j86lL02+vuHlqZNZ9eyYUGfIucgpq'
            + '4g/Iet3MwpS8SA3CZz894QGEE2Da9HwiffZr6lW4jrKNlhEug7FTepyIZCztTa9G'
            + 'x1YHPBA0r7DaUv+nIZ8eGt6aDP7KWYFdy8onwqIQ2/33Da3ueBl4lj915cU8VUPY'
            + 'ufmMeBSqElLSUvp4YpSO5XikD1H7IdXxypstPb8EpUWlgx8CeX083HZt8aHTBxcK'
            + 'jCHxteE3Zs37lqDQDq1nk69yzMshL+/qK1rCAwIDAQABAoIBAQCGEMlmaeLSqnvk'
            + 'ar4ts4hM8fh7+h2tAWKP35lheiwBrILhVHM1uWOO43TPXCM5UqPsn6F4Xl5aJL/x'
            + 'PBMKozlrZbjVN2o2rbTw+80Hf6unZ9W2IOxCPeQzF1o+SPSiig/x6YC7pj/sk6/Z'
            + 'rdOT/Jlm0+sJavgOO9Uyk2PazEmYnxGju2m5tMLHwQ1Gc2XkL6RgaVjs61pJrX1K'
            + 'EZc99YqiKvg8cH52WfMaSVzOz2ZEOi+hyrJoAhDX+Sy9wHfu9QlMgcdCcLzWb8Cp'
            + 'H5uyeT1IgribPP1q5VnxpRbhg120LQgDzil5Oqrek66wLulj9YyVR+0fA0zQYmSX'
            + 'EGtOu1ExAoGBAObdli2vxiVoyLSEAm0iTBWTUpnMSXpgHWDe9zRDrIn50BgyS4t9'
            + 'oWMfKHN4donhtMwkPWYjBs88wdHltubbCgzv7BW6EWD7rqm3MI3SN0yfg3IBUyt1'
            + 'z0v0FEFLZEdHOJE/JER7FOEbre8ggTS+aI8CVukqb0GuSTJI07clScFtAoGBALWq'
            + '1cahUkiCXsL0Gwyp33P10TPm2Dkc5TKRKWEMjlffuZ/0uPcMYFIpD8PrdlEqwXA4'
            + 'Yl+sgyuLwZDfpVDBF6WNbpdzhUfpUFJWpN79vdHjcClM193O3IkEEFZV765R11J7'
            + '72NTcvLn0tB/+YBO2FCTuE8yf06mM4xt3BmEuNsvAoGBALvuY4L7VFw9iSxRTbxT'
            + 'MAZcL+BcyO+icCfcOPXFpR2ISxp3TsHVWdvbkE03IZ+qKUgItCaBmth2R/y6d4JD'
            + 'ilHvuIoTNnRxTMSBCDhaiIOKUjEq3O5C76WPojFo0s+nLWgnMzm/y8ZXhuZi2mr6'
            + 'GRlZOTCDR5/65UDWwemTpA+dAoGAUT8sCH+RizgzJUGC73DxrKzdeTbesPxJTQo6'
            + '1VqGNqqqG+2Y43Q3h8cxc8/UxIw4ovW0mVFQAKOqWB6NksYoyzOrqDRUAUtJTunN'
            + 'JqWYxUvQl8f0KxEe9HBK1jHs1atof01KTMO/fv9K+1Cgx0970t2d6l2NLiGKoF1p'
            + 'uEfxXKUCgYEA4R+qLTRSZ/vjgOXzpwqNcEUT24kE2jOe+O3qqpkwdmqBlemNeHcU'
            + 'Nq/wbCNBNjr1cjElqKUkr4Or0G6o5P39EgQct4e+COPSy0InXBmYeRSySNQMru+N'
            + 'opEVS6bZw3EFbQ2aIXiaB3nYr5MGA1tbDYKx7r03sEMl/VpjZzPNR8I='
            + '-----END RSA PRIVATE KEY-----';
    }
    
    public String getAccessToken(){
        String accessToken = null;
        
        if( String.isNotBlank(this.tokenEndpoint) && String.isNotBlank(this.userNameEmail) 
           && String.isNotBlank(this.rsaPrivateKey) && String.isNotBlank(this.tokenExpirationTimeInSeconds) ){
               
          accessToken = getToken(this.tokenEndpoint, this.userNameEmail, this.rsaPrivateKey, this.tokenExpirationTimeInSeconds);
        }
        
        return accessToken;
    }
    
    public String getToken(String mTokenEndPoint, String mUserNameEmail, String mRsaPrivateKey, String mTokenExpirationTimeInSeconds) {
        
        // rsa private key reading : start
        String keyContents = mRsaPrivateKey;
        keyContents = keyContents.replace('-----BEGIN RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('-----END RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('\n', '');
        // rsa private key reading : end

        // Filling up required information to get a new token
        JWT jwt = new JWT('RS256');
        jwt.pkcs8 = keyContents;
        jwt.iss = 'developer.force.com';
        jwt.sub = mUserNameEmail;
        jwt.aud = mTokenEndPoint;
        jwt.exp = mTokenExpirationTimeInSeconds;
        
        // Get a new token
        String accessToken = JWTBearerFlow.getAccessToken(mTokenEndPoint, jwt);
        return accessToken;    
    }
}

global class TestJitHandler implements Auth.SamlJitHandler {
    
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map < String, String > attributes, String assertion) {
            
            User u;
            u = new User();
            String username = 'organo232+11@gmail.com';
            u.username = username;
            u.FederationIdentifier = federationIdentifier;
            
            u.Alias = 'Test';
            u.TimeZoneSidKey = 'Europe/Moscow';
            u.EmailEncodingKey = 'ISO-8859-1';
            u.LocaleSidKey = 'af_ZA';
            u.LanguageLocaleKey = 'en_US';
            u.Email = 'cheathac@purdue.edu';
            String profileName = 'Standard User';
            Profile p = [SELECT Id FROM profile WHERE name =:profileName LIMIT 1];
            u.profileId = p.Id;
            u.IsActive = TRUE;
            u.FirstName = 'Organo';
            u.LastName = 'Fashions';
            
            Insert u;
            return u;
        }
    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
                          String federationIdentifier, Map < String, String > attributes, String assertion){
                              User u = [SELECT Id, ContactId, IsActive FROM User WHERE Id=:userId];
                                  }
}


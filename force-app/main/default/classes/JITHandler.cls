global class JITHandler implements Auth.SamlJitHandler {
    
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map < String, String > attributes, String assertion) {
            
            User u;
            u = new User();
            String username = 'organo232+10@gmail.com';
            u.username = username;
            u.FederationIdentifier = federationIdentifier;
            
            u.Alias = 'Test';
            u.TimeZoneSidKey = 'Europe/Moscow';
            u.EmailEncodingKey = 'UTF-8';
            u.LocaleSidKey = 'af_ZA';
            u.LanguageLocaleKey = 'en_GB';
            u.Email = 'organo232@gmail.com';
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